//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 30.05.21.
//

import Cocoa

public extension NSLayoutConstraint {
	static func copyLayout(
		from container: NSView,
		for view: NSView,
		attributes: [NSLayoutConstraint.Attribute] = [.leading, .trailing, .top, .bottom],
		multiplier: [NSLayoutConstraint.Attribute: CGFloat] = [:],
		constant: [NSLayoutConstraint.Attribute: CGFloat] = [:]
	) -> [NSLayoutConstraint] {
		return attributes.map {
			NSLayoutConstraint(
				item: view, attribute: $0,
				relatedBy: .equal,
				toItem: container, attribute: $0,
				multiplier: multiplier[$0] ?? 1, constant: constant[$0] ?? 0
			)
		}
	}
	
	static func center(in container: NSView, for view: NSView) -> [NSLayoutConstraint] {
		return [
			NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0),
		]
	}
}
