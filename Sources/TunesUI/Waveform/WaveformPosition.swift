//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 29.05.21.
//

import Cocoa
import SwiftUI

public class WaveformPositionCocoa: NSView {
	public let waveformView: WaveformViewCocoa
	public let positionControl: PositionControlCocoa
	
	public init() {
		waveformView = .init()
		positionControl = .init()

		super.init(frame: NSRect())

		sharedInit()
	}
	
	required init?(coder: NSCoder) {
		waveformView = .init()
		positionControl = .init()

		super.init(coder: coder)

		sharedInit()
	}
	
	private func sharedInit() {
		for view in [waveformView, positionControl] {
			view.autoresizingMask = [.height, .width]
			view.frame = frame
			addSubview(view)
		}
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
