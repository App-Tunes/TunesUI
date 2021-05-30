//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 29.05.21.
//

import Cocoa
import SwiftUI

open class WaveformPositionCocoa: NSView {
	public let waveformView: WaveformViewCocoa
	public let positionControl: PositionControlCocoa
	
	public init() {
		waveformView = .init()
		positionControl = .init()

		super.init(frame: NSRect())

		sharedInit()
	}
	
	required public init?(coder: NSCoder) {
		waveformView = .init()
		positionControl = .init()

		super.init(coder: coder)

		sharedInit()
	}
	
	open func sharedInit() {
		for view in [waveformView, positionControl] {
			view.translatesAutoresizingMaskIntoConstraints = false
			view.frame = frame
			addSubview(view)
		}

		addConstraints(NSLayoutConstraint.copyLayout(from: self, for: waveformView, multiplier: [.top: 0.7]))
		addConstraints(NSLayoutConstraint.copyLayout(from: self, for: positionControl))
	}
}

struct WaveformPositionCocoa_Previews: PreviewProvider {
	struct MockView: NSViewRepresentable {
		@State var start = Date()

		public func makeNSView(context: NSViewRepresentableContext<MockView>) -> WaveformPositionCocoa {
			let nsView = WaveformPositionCocoa()
			nsView.waveformView.resample = Resample.nearest(_:toSize:)
			nsView.waveformView.waveform = WaveformView_Previews.waveform()
			return nsView
		}

		public func updateNSView(_ nsView: WaveformPositionCocoa, context: NSViewRepresentableContext<MockView>) {
			nsView.positionControl.range = 0...10
			nsView.positionControl.timer.fps = 5
			nsView.positionControl.locationProvider = {
				CGFloat(Date().timeIntervalSince(start))
			}
			nsView.positionControl.action = {
				switch $0 {
				case .absolute(let position):
					start = Date().addingTimeInterval(Double(-position))
				case .relative(let movement):
					start = start.addingTimeInterval(Double(-movement))
				}
			}
		}
	}

	static var previews: some View {
		MockView()
			.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
