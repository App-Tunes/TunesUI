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
	
	static public var empty: Waveform = .init(loudness: [], pitch: [])
}
