//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 24.05.21.
//

import Cocoa
import Combine

public class DisplayTimer {
	public var action: (() -> Void)?
	public var enabled: Bool = true {
		didSet { updateTimer() }
	}
	public var fps: Double

	private var timer: Timer?
	
	public init(fps: Double = 10, enabled: Bool = true, action: (() -> Void)?) {
		self.fps = fps
		self.enabled = enabled
		self.action = action
		
		updateTimer()
		// TODO only fire if visible
	}
	
	private func updateTimer() {
		guard enabled else {
			timer?.invalidate()
			timer = nil
			return
		}
		
		timer = .scheduledTimer(withTimeInterval: 1 / fps, repeats: true) { [weak self] timer in
			self?.action?()
		}
		timer?.tolerance = (1 / fps) / 5
	}
}
