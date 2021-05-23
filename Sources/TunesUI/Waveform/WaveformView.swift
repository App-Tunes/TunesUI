//
//  WaveformView.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 01.04.21.
//

import Cocoa
import SwiftUI

public class WaveformLayer: CALayer {
	public var colorLUT: [CGColor] { didSet {
		if colorLUT != oldValue { setNeedsLayout() }
	} }
	public var waveform: Waveform { didSet {
		if waveform != oldValue { setNeedsLayout() }
	} }
	public var spacing: CGFloat = 1 { didSet {
		if spacing != oldValue { setNeedsLayout() }
	} }
	
	public init(colorLUT: [CGColor]) {
		self.colorLUT = colorLUT
		self.waveform = .empty
		super.init()
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func ensureSublayerCount<T: CALayer>(_ count: Int, of kind: T.Type) {
		let diffLayers = count - ((sublayers as? [T])?.count ?? 0)
		
		if diffLayers > 0 {
			sublayers = (sublayers ?? []) + (0 ..< diffLayers).map { _ in
				kind.init()
			}
		}
		else if diffLayers < 0 {
			sublayers?.removeLast(-diffLayers)
		}
	}
	
	public override func layoutSublayers() {
		// Multithreading safety, just in case
		let waveform = self.waveform
		let colorLUT = self.colorLUT
		let barCount = waveform.count
		
		ensureSublayerCount(barCount, of: CAShapeLayer.self)
		
		let barWidth = frame.size.width / (CGFloat(barCount) * (1 + spacing))
		let barWidthHalf = barWidth / 2
		let stride = frame.size.width / CGFloat(barCount)
		
		let lutCount = Float(colorLUT.count)
		
		for i in 0 ..< barCount {
			let center = (CGFloat(i) + 0.5) * stride
			let layer = sublayers![i]

			layer.frame = CGRect(
				x: center - barWidthHalf,
				y: frame.minY,
				width: barWidth,
				height: CGFloat(waveform.loudness[i]) * frame.height
			)
			layer.backgroundColor = colorLUT[min(colorLUT.count - 1, max(0, Int(waveform.pitch[i] * lutCount)))]
		}
	}
	
	public func updateWaveform(_ waveform: Waveform, duration: CFTimeInterval) {
		guard self.waveform != waveform else {
			return
		}
		
		guard duration > 0 else {
			self.waveform = waveform
			return
		}
		
		CATransaction.begin()
		CATransaction.setAnimationDuration(duration)
		CATransaction.setAnimationTimingFunction(.init(name: .linear))

		self.waveform = waveform

		CATransaction.commit()
	}
}

public class WaveformViewCocoa: NSView {
	public init(frame frameRect: NSRect, colorLUT: [CGColor]) {
		super.init(frame: frameRect)

		self.wantsLayer = true
		layer = WaveformLayer(colorLUT: colorLUT)
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var waveformLayer: WaveformLayer { layer as! WaveformLayer }
	
	public var colorLUT: [CGColor] {
		get { waveformLayer.colorLUT }
		set { waveformLayer.colorLUT = newValue }
	}

	public var waveform: Waveform {
		get { waveformLayer.waveform }
		set { waveformLayer.waveform = newValue }
	}

	public var spacing: CGFloat {
		get { waveformLayer.spacing }
		set { waveformLayer.spacing = newValue }
	}
	
	public func updateWaveform(_ waveform: Waveform, duration: CFTimeInterval) {
		waveformLayer.updateWaveform(waveform, duration: duration)
	}
}

struct WaveformView: NSViewRepresentable {
	public var colorLUT: [CGColor]
	public var waveform: Waveform
	public var spacing: Float = 1
	public var changeDuration: TimeInterval = 0.2
	
	public init(
		colorLUT: [CGColor],
		waveform: Waveform,
		spacing: Float = 1,
		changeDuration: TimeInterval = 0.2
	) {
		self.colorLUT = colorLUT
		self.waveform = waveform
		self.spacing = spacing
		self.changeDuration = changeDuration
	}

	public func makeNSView(context: NSViewRepresentableContext<WaveformView>) -> WaveformViewCocoa {
		let view = WaveformViewCocoa(frame: NSRect(), colorLUT: colorLUT)
		view.waveform = waveform
		view.spacing = CGFloat(spacing)
		return view
	}

	public func updateNSView(_ nsView: WaveformViewCocoa, context: NSViewRepresentableContext<WaveformView>) {
		nsView.colorLUT = colorLUT
		nsView.updateWaveform(waveform, duration: changeDuration)
		nsView.spacing = CGFloat(spacing)
	}
}

struct WaveformView_Previews: PreviewProvider {
	static func waveform(shift: Float = 0) -> Waveform {
		Waveform(
			loudness: (0...80).map {
				(sin((Float($0) + shift) / 3) + 1) / 2
			},
			pitch: (0...80).map {
				(sin((Float($0) + shift * 0.3) / 2) + 1) / 2
			}
		)
	}
	
	struct MockView: View {
		@State var shift: Float = 0.0
		
		var body: some View {
			VStack {
				Slider(value: $shift, in: 0...20)
				
				WaveformView(
					colorLUT: Gradients.pitchCG,
					waveform: waveform(shift: shift)
				)
			}
		}
	}

	static var previews: some View {
		MockView()
	}
}
