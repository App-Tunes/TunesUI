//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 12.07.22.
//

import SwiftUI

class MockAudioDevice: AudioDevice {
	var id = UUID()
	var name: String?
	var icon: Image
	var volume: Double
	
	init(name: String?, icon: Image, volume: Double = 1) {
		self.name = name
		self.icon = icon
		self.volume = volume
	}
	
	static func == (lhs: MockAudioDevice, rhs: MockAudioDevice) -> Bool {
		lhs.id == rhs.id
	}
}

class MockAudioDeviceProvider: AudioDeviceProvider {
	static let defaultOptions: [MockAudioDevice] = [
		MockAudioDevice(name: "Speakers", icon: .init(systemName: "hifispeaker")),
		MockAudioDevice(name: "Bluetooth", icon: .init(systemName: "wave.3.right.circle")),
		MockAudioDevice(name: "Airplay", icon: .init(systemName: "airplayaudio")),
	]
	
	let options = defaultOptions
	var icon: Image { Image(systemName: "speaker.wave.2.circle") }
	var color: Color { .primary }
}

struct MockAudioDeviceProvider_Previews: PreviewProvider {
	static var previews: some View {
		AudioProviderView(provider: MockAudioDeviceProvider(), current: .constant(MockAudioDeviceProvider.defaultOptions.first!))
	}
}
