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


public struct TransitioningImageView: NSViewRepresentable {
	public var image: NSImage?
	public var duration: Double = 0.2
	public var timing: CAMediaTimingFunctionName = .easeInEaseOut
	public var scaling: NSImageScaling = .scaleAxesIndependently
	
	public init(_ image: NSImage?, duration: Double = 0.2, timing: CAMediaTimingFunctionName = .easeInEaseOut, scaling: NSImageScaling = .scaleAxesIndependently) {
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
	struct TickingImageView: View {
		var images: [NSImage]
		@State var image: NSImage? = nil
		
		var body: some View {
			VStack {
				HStack {
					ForEach(0..<images.count) { i in
						let image = images[i]
						Button("Image \(i)") {
							self.image = image
						}
					}
				}
				
				TransitioningImageView(image)
			}
		}
	}
	
    static var previews: some View {
		return TickingImageView(images: [
			NSImage(named: NSImage.folderBurnableName)!,
			NSImage(named: NSImage.folderSmartName)!,
		])
    }
}
