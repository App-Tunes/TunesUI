//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 19.07.22.
//

import Foundation

extension Array {
	public var fullSlice: ArraySlice<Element> {
		self[indices]
	}
}
