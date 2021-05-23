//
//  Waveform.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 02.04.21.
//

import Foundation

struct Waveform: Hashable, Codable {
	var loudness: [Float]
	var pitch: [Float]
	
	var count: Int { min(loudness.count, pitch.count) }
	
	static var empty: Waveform = .init(loudness: [], pitch: [])
}
