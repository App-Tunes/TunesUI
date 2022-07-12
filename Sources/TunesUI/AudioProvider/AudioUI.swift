//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 12.07.22.
//

import SwiftUI

enum AudioUI {
	static func imageForVolume(_ volume: Double) -> Image {
		Image(systemName:
			volume == 0 ? "speaker.fill" :
			volume < 0.33 ? "speaker.wave.1.fill" :
			volume < 0.66 ? "speaker.wave.2.fill" :
			"speaker.wave.3.fill"
		)
	}
}
