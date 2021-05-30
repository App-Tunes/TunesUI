//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 30.05.21.
//

import Foundation

public class Resample {
	static public func nearest<T: BinaryFloatingPoint>(_ data: [T], toSize size: Int) -> [T] {
		guard data.count > 0 else {
			return Array(repeating: .nan, count: size)
		}
		
		let ratio = T(data.count - 1) / T(size - 1)
		return (0..<size).map {
			data[Int(round(T($0) * ratio))]
		}
	}
}
