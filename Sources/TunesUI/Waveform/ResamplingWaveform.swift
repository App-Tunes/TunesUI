//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 23.05.21.
//

import Foundation
import Combine

public class ResamplingWaveform: ObservableObject {
	public typealias Resampler = ([Float], Int) throws -> [Float]
	
	public var debounce: TimeInterval {
		didSet {
			if oldValue != debounce { observe() }
		}
	}
	public var qos: DispatchQoS.QoSClass = .default {
		didSet {
			if oldValue != qos { observe() }
		}
	}
	
	@Published public var source: Waveform? = nil
	@Published public var desiredCount: Int = 0
	@Published public var resample: Resampler?

	@Published public var waveform: Waveform = .empty
	
	private var observer: AnyCancellable?

	public init(debounce: TimeInterval, resample: Resampler?) {
		self.debounce = debounce
		self.resample = resample
		
		observe()
	}
	
	private func observe() {
		let scheduler = DispatchQueue.global(qos: qos)
		
		let liveCount = $desiredCount
			.debounce(for: .seconds(debounce), scheduler: scheduler)
			.removeDuplicates()
		
		observer = $source.combineLatest(liveCount, $resample)
			.receive(on: scheduler)
			.map(Self.resample)
			.receive(on: RunLoop.main)
			.sink { [weak self] in
				self?.waveform = $0
			}
	}
	
	private static func resample(waveform: Waveform?, samples: Int, resample: Resampler?) -> Waveform {
		guard let resample = resample else {
			return waveform ?? Waveform.zero(count: samples)
		}
		
		guard
			let source = waveform,
			let loudness = try? resample(source.loudness, samples),
			let pitch = try? resample(source.pitch, samples)
		else {
			return Waveform.zero(count: samples)
		}
						
		return Waveform(loudness: loudness, pitch: pitch)
	}
	
	public static func constant(_ waveform: Waveform, resample: Resampler?) -> ResamplingWaveform {
		let rs = ResamplingWaveform(debounce: 0, resample: resample)
		rs.source = waveform
		rs.desiredCount = waveform.count
		return rs
	}
	
	public func updateSamples(_ desired: Int) {
		setIfDifferent(self, \.desiredCount, desired)
	}
	
	public var loudness: [Float] { waveform.loudness }
	public var pitch: [Float] { waveform.pitch }
}

extension ResamplingWaveform {
	static func resampleNearest(_ data: [Float], toSize size: Int) -> [Float] {
		let ratio = Float(data.count - 1) / Float(size - 1)
		return (0..<size).map {
			data[Int(round(Float($0) * ratio))]
		}
	}
}
