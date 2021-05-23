//
//  Waveform.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 02.04.21.
//

import Foundation

public struct Waveform: Hashable, Codable {
	public var loudness: [Float]
	public var pitch: [Float]
	
	public var count: Int { min(loudness.count, pitch.count) }
	
	public init(loudness: [Float], pitch: [Float]) {
		self.loudness = loudness
		self.pitch = pitch
	}
	
	static public var empty: Waveform = .init(loudness: [], pitch: [])
}
