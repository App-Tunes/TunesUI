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
		waveformView.autoresizingMask = [.height, .width]
		
		positionControl = .init()
		positionControl.autoresizingMask = [.height, .width]

		super.init(frame: NSRect())

		addSubview(waveformView)
		addSubview(positionControl)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

struct WaveformPositionCocoa_Previews: PreviewProvider {
	struct MockView: NSViewRepresentable {
		@State var start = Date()

		public func makeNSView(context: NSViewRepresentableContext<MockView>) -> WaveformPositionCocoa {
			let nsView = WaveformPositionCocoa()
			nsView.waveformView.resample = ResamplingWaveform.resampleNearest(_:toSize:)
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
