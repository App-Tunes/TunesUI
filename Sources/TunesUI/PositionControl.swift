//
//  PositionControl.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 03.04.21.
//

import Cocoa
import SwiftUI

public enum PositionMovement {
	case relative(CGFloat)
	case absolute(CGFloat)
}

public class PositionControlCocoa: NSView {
	public var range: ClosedRange<CGFloat> = 1...1 {
		didSet { needsLayout = true }
	}
	
	public var locationProvider: () -> CGFloat? = { nil } {
		didSet { needsLayout = true }
	}

	public var jumpInterval: CGFloat? {
		didSet { needsLayout = true }
	}
	public var useJumpInterval: (() -> Bool)?
	
	public var action: ((PositionMovement) -> Void)?
	
	// ------------------------------- Display
	
	public var barWidth: CGFloat = 2 {
		didSet { needsLayout = true }
	}

	public var barColor: CGColor = NSColor.controlTextColor.cgColor {
		didSet { needsLayout = true }
	}
	public var hoverColor: CGColor = NSColor.controlColor.cgColor {
		didSet { needsLayout = true }
	}

	private let locationLayer: CAShapeLayer = CAShapeLayer()
	private let hoverLayer: CAShapeLayer = CAShapeLayer()
	
	private var isMouseInside = false
	private var mouseLocation: CGFloat? = nil
	private var trackingArea: NSTrackingArea?

	public let timer: DisplayTimer = DisplayTimer(action: nil)

	// shoddy helpers for better animations
	private var isMouseFreeHovering = true

	public init() {
		super.init(frame: NSRect())

		self.wantsLayer = true

		for layer in [locationLayer, hoverLayer] {
			layer.backgroundColor = self.barColor
			layer.isHidden = true
			layer.delegate = self
			self.layer!.addSublayer(layer)
		}
		
		timer.action = { [weak self] in
			self?.update()
		}
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func updateTrackingAreas() {
		trackingArea.map(removeTrackingArea)
		// TODO How to update during drag?
		trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .inVisibleRect, .activeAlways], owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
	}
		
	@discardableResult
	private func setLocation(_ layer: CALayer, position: CGFloat?) -> Bool {
		guard let position = position else {
			layer.isHidden = true
			return false
		}
		
		layer.frame = NSRect(
			x: convertRangeToView(position) - barWidth / 2,
			y: 0,
			width: barWidth,
			height: frame.height
		)

		layer.isHidden = false
		return true
	}
	
	private func currentMovement(_ location: CGFloat?) -> CGFloat? {
		guard
			useJumpInterval?() ?? true,
			let jumpInterval = jumpInterval,
			let location = location,
			let mouseLocation = mouseLocation
		else {
			return nil
		}
		
		return round((mouseLocation - location) / jumpInterval) * jumpInterval
	}
		
	private func update() {
		func _setLocation(layer: CALayer, location: CGFloat?, jump: Bool) {
			CATransaction.begin()
			CATransaction.setAnimationTimingFunction(.init(name: .linear))
												
			if jump || layer.isHidden {
				CATransaction.setDisableActions(true)
				CATransaction.setAnimationDuration(0)
			}
			else {
				CATransaction.setAnimationDuration(1 / timer.fps)
			}

			setLocation(layer, position: location)
			
			CATransaction.commit()
		}
		
		let location = locationProvider()
		_setLocation(
			layer: locationLayer, location: location,
			jump: false
		)

		if let location = location, let movement = currentMovement(location) {
			_setLocation(
				layer: hoverLayer,
				location: movement + location,
				jump: isMouseFreeHovering
			)
			isMouseFreeHovering = false
		}
		else if !isMouseFreeHovering {
			setLocation(hoverLayer, position: mouseLocation)
		}
	}
	
	public override func layout() {
		// Did change size, better redraw!
		update()
		super.layout()
	}

	private func convertViewToRange(_ location: CGFloat) -> CGFloat {
		location / frame.width * (range.upperBound - range.lowerBound) + range.lowerBound
	}

	private func convertRangeToView(_ location: CGFloat) -> CGFloat {
		(location - range.lowerBound) / (range.upperBound - range.lowerBound) * frame.width
	}
	
	private func updateMouseLocation(_ locationInWindow: CGPoint) {
		mouseLocation = convertViewToRange(convert(locationInWindow, from: nil).x)
		
		// 0 is just for mock, makes it easier to call it
		if currentMovement(locationLayer.isHidden ? nil : 0) == nil {
			isMouseFreeHovering = true
			
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			CATransaction.setAnimationDuration(0)

			setLocation(hoverLayer, position: mouseLocation)
			
			CATransaction.commit()
		}
		
		hoverLayer.backgroundColor = (NSEvent.pressedMouseButtons & 1) != 0 ? barColor : hoverColor
	}

	public override func mouseDown(with event: NSEvent) {
		needsLayout = true
		updateMouseLocation(event.locationInWindow)
	}

	public override func mouseUp(with event: NSEvent) {
		needsLayout = true
		updateMouseLocation(event.locationInWindow)
		
		if isMouseInside {
			if let movement = currentMovement(locationProvider()), movement != 0 {
				action?(.relative(movement))
			}
			else {
				action?(.absolute(convertViewToRange(hoverLayer.position.x)))
			}
		}
	}

	public override func mouseEntered(with event: NSEvent) {
		isMouseInside = true
		updateMouseLocation(event.locationInWindow)
	}

	public override func mouseMoved(with event: NSEvent) {
		if isMouseInside {
			updateMouseLocation(event.locationInWindow)
		}
	}

	public override func mouseDragged(with event: NSEvent) {
		if isMouseInside {
			updateMouseLocation(event.locationInWindow)
		}
	}

	public override func mouseExited(with event: NSEvent) {
		isMouseInside = false
		setLocation(hoverLayer, position: nil)
		mouseLocation = nil
	}
}

extension PositionControlCocoa: CALayerDelegate {
	public func action(for layer: CALayer, forKey event: String) -> CAAction? {
		if event == "bounds" || event == "position" {
			return inLiveResize ? NSNull() : nil
		}
		
		return nil
	}
}

public struct PositionControlView: NSViewRepresentable {
	public var locationProvider: () -> CGFloat?
	public var range: ClosedRange<CGFloat>
	
	public var action: ((PositionMovement) -> Void)?
	
	public var jumpInterval: CGFloat?
	public var useJumpInterval: (() -> Bool)?
	
	public var barWidth: CGFloat = 2
	public var barColor: CGColor = NSColor.controlTextColor.cgColor
	public var hoverColor: CGColor = NSColor.controlColor.cgColor
	
	public init(
		locationProvider: @escaping () -> CGFloat?,
		range: ClosedRange<CGFloat> = 0...1,
		action: ((PositionMovement) -> Void)? = nil
	) {
		self.locationProvider = locationProvider
		self.range = range
		self.action = action
	}
	
	public func jumpInterval(_ jumpInterval: CGFloat?, useWhen: (() -> Bool)? = nil) -> PositionControlView {
		var copy = self
		copy.jumpInterval = jumpInterval
		copy.useJumpInterval = useWhen
		return copy
	}
	
	public func barWidth(_ barWidth: CGFloat) -> PositionControlView {
		var copy = self
		copy.barWidth = barWidth
		return copy
	}

	public func barColor(_ barColor: CGColor, hover: CGColor = NSColor.controlColor.cgColor) -> PositionControlView {
		var copy = self
		copy.barColor = barColor
		copy.hoverColor = hover
		return copy
	}

	public func makeNSView(context: NSViewRepresentableContext<PositionControlView>) -> PositionControlCocoa {
		PositionControlCocoa()
	}
	
	public func updateNSView(_ nsView: PositionControlCocoa, context: NSViewRepresentableContext<PositionControlView>) {
		
		nsView.locationProvider = locationProvider
		nsView.range = range
		
		nsView.action = action

		nsView.jumpInterval = jumpInterval
		nsView.useJumpInterval = useJumpInterval
		
		nsView.barWidth = barWidth
		nsView.barColor = barColor
		nsView.hoverColor = hoverColor
	}
}

struct PositionControlView_Previews: PreviewProvider {
	@State var isOptionDown = false
	
	static var previews: some View {
		var start = Date()

		return PositionControlView(
			locationProvider: {
					CGFloat(Date().timeIntervalSince(start))
			 },
			range: 0...10,
			action: {
				switch $0 {
				case .absolute(let position):
					start = Date().addingTimeInterval(Double(-position))
				case .relative(let movement):
					start = start.addingTimeInterval(Double(-movement))
				}
			}
		)
		.jumpInterval(1) {
			!NSEvent.modifierFlags.contains(.option)
		}
	}
}
