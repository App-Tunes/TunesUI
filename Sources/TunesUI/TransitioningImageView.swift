//
//  SwiftUIView.swift
//  
//
//  Created by Lukas Tenbrink on 23.05.21.
//

import SwiftUI
import Cocoa

extension NSImageView {
	public func transitionWithImage(image: NSImage?, duration: Double = 0.2, timing: CAMediaTimingFunctionName = .easeInEaseOut) {
		let transition = CATransition()
		transition.duration = duration
		transition.timingFunction = CAMediaTimingFunction(name: timing)
		transition.type = .fade
		
		wantsLayer = true
		layer?.add(transition, forKey: kCATransition)
		
		self.image = image
	}
}


struct TransitioningImageView: NSViewRepresentable {
	public var image: NSImage
	public var duration: Double = 0.2
	public var timing: CAMediaTimingFunctionName = .easeInEaseOut
	public var scaling: NSImageScaling = .scaleAxesIndependently
	
	public init(_ image: NSImage, duration: Double = 0.2, timing: CAMediaTimingFunctionName = .easeInEaseOut, scaling: NSImageScaling = .scaleAxesIndependently) {
		self.image = image
		self.duration = duration
		self.timing = timing
		self.scaling = scaling
	}
	
	public func makeNSView(context: NSViewRepresentableContext<TransitioningImageView>) -> NSImageView {
		let view = NSImageView()
		view.imageScaling = scaling
		return view
	}

	public func updateNSView(_ nsView: NSImageView, context: NSViewRepresentableContext<TransitioningImageView>) {
		nsView.transitionWithImage(image: image, duration: duration, timing: timing)
	}
}

struct TransitioningImageView_Previews: PreviewProvider {
	class TickingWrapper<Object>: ObservableObject {
		@Published var state: Object
		var timer: Timer?
		
		init(_ states: [Object]) {
			var i = 0
			
			self.state = states.first!
			
			timer = .scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
				let c = i % states.count
				let img = states[c]
				self?.state = img
				i += 1
			})
		}
	}
	
	struct TickingImageView: View {
		@ObservedObject var ticker: TickingWrapper<NSImage>
		
		var body: some View {
			TransitioningImageView(ticker.state)
		}
	}
	
    static var previews: some View {
		let ticker = TickingWrapper([
			NSImage(named: NSImage.folderBurnableName)!,
			NSImage(named: NSImage.folderSmartName)!,
		])
		
		return TickingImageView(ticker: ticker)
    }
}
