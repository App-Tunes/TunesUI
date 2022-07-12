//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 12.07.22.
//

import SwiftUI

@available(OSX 10.15, *)
public protocol AudioDeviceProvider: ObservableObject {
	associatedtype Option: AudioDevice
	
	var options: [Option] { get }

	var icon: Image { get }
	var color: Color { get }
}
