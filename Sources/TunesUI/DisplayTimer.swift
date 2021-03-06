//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 24.05.21.
//

import Cocoa
import Combine
import SwiftUI

public class DisplayTimer {
	public var action: (() -> Void)?
	public var fps: Double? {
		didSet {
			if fps != oldValue { updateTimer() }
		}
	}
	
	private var isVisibleObserver: NSObjectProtocol?
	public var isVisible = true {
		didSet {
			if isVisible != oldValue {
				updateTimer()
				if isVisible {
					// Changed to visible; let's fire now to catch up
					// Timer is re-constructed and won't fire until date.
					self.action?()
				}
			}
		}
	}

	private var timer: Timer?
	
	public init(fps: Double?, action: (() -> Void)?, forView view: NSView? = nil) {
		self.fps = fps
		self.action = action
		
		updateTimer()
		// TODO only fire if visible
	}
	
	private func updateTimer() {
		guard let fps = fps, isVisible else {
			timer?.invalidate()
			timer = nil
			return
		}
		
		timer = .scheduledTimer(withTimeInterval: 1 / fps, repeats: true) { [weak self] timer in
			self?.action?()
		}
		timer?.tolerance = (1 / fps) / 5
	}
	
	public func observeOcclusion(ofView view: NSView) {
		isVisible = view.window?.occlusionState.contains(.visible) ?? false
		
		isVisibleObserver = view.window == nil
			? nil
			: NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: view.window!, queue: .main) { [weak self] notification in
				self?.isVisible = (notification.object as? NSWindow)?.occlusionState.contains(.visible) ?? false
		}
	}
}

public class DisplayTimerViewCocoa: NSView {
	public let timer: DisplayTimer
	
	public init(timer: DisplayTimer) {
		self.timer = timer
		super.init(frame: NSRect())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidMoveToWindow() {
		timer.observeOcclusion(ofView: self)
	}
}

public struct DisplayTimerView: NSViewRepresentable {
	public var action: (() -> Void)?
	public var fps: Double?

	public init(
		fps: Double?,
		action: (() -> Void)?
	) {
		self.action = action
		self.fps = fps
	}
	
	public func makeNSView(context: NSViewRepresentableContext<DisplayTimerView>) -> DisplayTimerViewCocoa {
		DisplayTimerViewCocoa(timer: DisplayTimer(fps: nil, action: nil))
	}
	
	public func updateNSView(_ nsView: DisplayTimerViewCocoa, context: NSViewRepresentableContext<DisplayTimerView>) {
		nsView.timer.action = action
		nsView.timer.fps = fps
	}
}

extension View {
	func whileVisibleRunTimer(fps: Double?, action: @escaping () -> Void) -> some View {
		background(DisplayTimerView(fps: fps, action: action))
	}
}
