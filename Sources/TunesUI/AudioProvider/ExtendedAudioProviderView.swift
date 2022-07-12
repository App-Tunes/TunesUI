//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 12.07.22.
//

import SwiftUI

public struct ExtendedAudioDeviceView<Device: AudioDevice>: View {
	@ObservedObject public var device: Device
	
	public init(device: Device) {
		self.device = device
	}
	
	public var body: some View {
		HStack {
			Slider(value: $device.volume, in: 0...1)
			
			AudioUI.imageForVolume(device.volume)
				.frame(width: 25, alignment: .leading)
		}
	}
}
