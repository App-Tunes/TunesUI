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
	
	@Published public var source: Waveform = .empty
	@Published public var desiredCount: Int = 0

	@Published public var waveform: Waveform = .empty
	
	private var observer: AnyCancellable?

	public init(debounce: TimeInterval, resample: @escaping Resampler) {
		observer = $source.combineLatest($desiredCount)
			.debounce(for: .seconds(debounce), scheduler: DispatchQueue.global(qos: .default))
			.removeDuplicates { l, r in
				l.0 == r.0 && l.1 == r.1
			}
			.map { [weak self] waveform, samples in
				guard let source = self?.source else { return Waveform.empty }
				
				return Waveform(
					loudness: (try? resample(source.loudness, samples)) ?? [],
					pitch: (try? resample(source.pitch, samples)) ?? []
				)
			}
			.receive(on: RunLoop.main)
			.sink { [weak self] in
				self?.waveform = $0
			}
	}
	
	public static func constant(_ waveform: Waveform, resample: @escaping Resampler) -> ResamplingWaveform {
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
