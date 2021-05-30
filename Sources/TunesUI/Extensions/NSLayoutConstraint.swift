//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 30.05.21.
//

import Cocoa

extension NSLayoutConstraint {
	static func copyLayout(from container: NSView, for view: NSView) -> [NSLayoutConstraint] {
		return [
			NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0),
		]
	}
	
	static func center(in container: NSView, for view: NSView) -> [NSLayoutConstraint] {
		return [
			NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0),
		]
	}
}
