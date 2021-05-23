//
//  HoverPositionView.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 01.01.21.
//

import SwiftUI

public class NSHoverPosition: NSView {
	public var onChanged:  (CGPoint) -> Void
	public var onEnded:  () -> Void

	public var isInside = false
	
	private var trackingArea: NSTrackingArea?

	public init(onChanged: @escaping (CGPoint) -> Void, onEnded: @escaping () -> Void) {
		self.onChanged = onChanged
		self.onEnded = onEnded
		super.init(frame: NSRect())
	}
	
	public override func viewWillMove(toWindow newWindow: NSWindow?) {
		newWindow?.acceptsMouseMovedEvents = true
	}
	
	required public init?(coder: NSCoder) { fatalError() }
	
	public override func updateTrackingAreas() {
		trackingArea.map(removeTrackingArea)
		// TODO How to update during drag?
		trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .inVisibleRect, .activeAlways], owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	public override func mouseEntered(with event: NSEvent) {
		let location = convert(event.locationInWindow, from: nil)
		onChanged(location)
		isInside = true
	}

	public override func mouseMoved(with event: NSEvent) {
		if isInside {
			let location = convert(event.locationInWindow, from: nil)
			onChanged(location)
		}
	}

	public override func mouseExited(with event: NSEvent) {
		onEnded()
		isInside = false
	}
}

public struct HoverPosition: NSViewRepresentable {
	public var onChanged:  (CGPoint) -> Void
	public var onEnded:  () -> Void

	public func makeNSView(context: NSViewRepresentableContext<HoverPosition>) -> NSHoverPosition {
		NSHoverPosition(onChanged: onChanged, onEnded: onEnded)
	}

	public func updateNSView(_ nsView: NSHoverPosition, context: NSViewRepresentableContext<HoverPosition>) {
		nsView.onChanged = onChanged
		nsView.onEnded = onEnded
	}
}

extension View {
	public func onHoverLocation(onChanged: @escaping (CGPoint) -> Void = {_ in }, onEnded: @escaping () -> Void = {}) -> some View {
		background(HoverPosition(onChanged: onChanged, onEnded: onEnded))
	}
}
