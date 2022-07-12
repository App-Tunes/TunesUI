//
//  AnyAudioDevice.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 21.03.21.
//

import SwiftUI

public protocol AudioDevice: ObservableObject, Identifiable, Equatable {
	var name: String? { get }
	var icon: Image { get }

	var volume: Double { get set }
}

class UnsupportedAudioDeviceError: LocalizedError {
	var errorDescription: String? {
		"Track is not compatible with any of the selected audio devices."
	}
}
