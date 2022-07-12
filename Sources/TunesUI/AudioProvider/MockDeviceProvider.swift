//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 12.07.22.
//

import SwiftUI

public class MockAudioDevice: AudioDevice {
	public var id = UUID()
	public var name: String?
	public var icon: Image
	public var volume: Double
	
	public init(name: String?, icon: Image, volume: Double = 1) {
		self.name = name
		self.icon = icon
		self.volume = volume
	}
	
	public static func == (lhs: MockAudioDevice, rhs: MockAudioDevice) -> Bool {
		lhs.id == rhs.id
	}
}

public class MockAudioDeviceProvider: AudioDeviceProvider {
	public static let defaultOptions: [MockAudioDevice] = [
		MockAudioDevice(name: "Speakers", icon: .init(systemName: "hifispeaker")),
		MockAudioDevice(name: "Bluetooth", icon: .init(systemName: "wave.3.right.circle")),
		MockAudioDevice(name: "Airplay", icon: .init(systemName: "airplayaudio")),
	]
	
	public let options = defaultOptions
	public var icon: Image { Image(systemName: "speaker.wave.2.circle") }
	public var color: Color { .primary }
}

struct MockAudioDeviceProvider_Previews: PreviewProvider {
	static var previews: some View {
		AudioProviderView(provider: MockAudioDeviceProvider(), current: .constant(MockAudioDeviceProvider.defaultOptions.first!))
	}
}
