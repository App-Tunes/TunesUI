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
