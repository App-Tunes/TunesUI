//
//  WaveformView.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 01.04.21.
//

import Cocoa
import SwiftUI
import Combine

extension CAAnimation {
	static func linear(duration: TimeInterval) -> CAAnimation {
		let animation = CAAnimation()
		animation.duration = duration
		animation.timingFunction = .init(name: .linear)
		return animation
	}
}

public class WaveformViewCocoa: NSView {
	public var colorLUT: [CGColor] { didSet {
		if colorLUT != oldValue { needsLayout = true }
	} }
	public var spacing: CGFloat = 1 { didSet {
		if spacing != oldValue { needsLayout = true }
	} }
	public var changeDuration: CFTimeInterval = 0.2
	public var pixelsPerBar: CGFloat = 4 { didSet {
		calculateDesiredCount()
	} }

	private let resamplingWaveform: ResamplingWaveform
	private var waveformObserver: AnyCancellable?
	
	private var didChangeFrame: Bool = true
	
	public private(set) var displayWaveform: Waveform = .empty { didSet {
		if displayWaveform != oldValue { needsLayout = true }
	} }

	public init(colorLUT: [CGColor], debounce: TimeInterval = 0.2) {
		self.colorLUT = colorLUT
		self.resamplingWaveform = .init(debounce: debounce, resample: nil)
		super.init(frame: NSRect())

		wantsLayer = true
		layer!.contentsGravity = .bottom
		layer!.delegate = self
//		layer!.actions = [
//			kCAOnOrderIn: NSNull(),
//			kCAOnOrderOut: NSNull(),
//			"sublayers": NSNull(),
//			"contents": NSNull(),
//			"bounds": NSNull(),
//			"position": NSNull(),
//			"hidden": NSNull(),
//		]

		waveformObserver = resamplingWaveform.$waveform.sink { [weak self] in
			self?.updateDisplayWaveform($0)
		}
	}
	
	public var waveform: Waveform? {
		get { resamplingWaveform.source }
		set { resamplingWaveform.source = newValue }
	}
	
	public var resample: ResamplingWaveform.Resampler? {
		get { resamplingWaveform.resample }
		set { resamplingWaveform.resample = newValue }
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func calculateDesiredCount() {
		resamplingWaveform.desiredCount = Int(frame.size.width / pixelsPerBar)
	}
	
	private func ensureSublayerCount<T: CALayer>(_ count: Int, of kind: T.Type) {
		let diffLayers = count - ((layer!.sublayers as? [T])?.count ?? 0)
		
		if diffLayers > 0 {
			let actions = self.layer!.actions
			
			layer!.sublayers = (layer!.sublayers ?? []) + (0 ..< diffLayers).map { _ in
				let layer = kind.init()
				layer.delegate = self
				layer.actions = actions
				return layer
			}
			didChangeFrame = true
		}
		else if diffLayers < 0 {
			layer!.sublayers?.removeLast(-diffLayers)
			didChangeFrame = true
		}
	}
	
	public override func layout() {
		calculateDesiredCount()

		// Multithreading safety, just in case
		let waveform = self.displayWaveform
		let colorLUT = self.colorLUT
		let barCount = waveform.count
		
		ensureSublayerCount(barCount, of: CAShapeLayer.self)
		
		let barWidth = frame.size.width / (CGFloat(barCount) * (1 + spacing))
		let barWidthHalf = barWidth / 2
		let stride = frame.size.width / CGFloat(barCount)
		
		let lutCount = Float(colorLUT.count)
		
		for i in 0 ..< barCount {
			let center = (CGFloat(i) + 0.5) * stride
			let layer = layer!.sublayers![i]

			layer.frame = CGRect(
				x: center - barWidthHalf,
				y: frame.minY,
				width: barWidth,
				height: CGFloat(waveform.loudness[i]) * frame.height
			)
			layer.backgroundColor = colorLUT[min(colorLUT.count - 1, max(0, Int(waveform.pitch[i] * lutCount)))]
		}
		didChangeFrame = false

		super.layout()
	}
	
	private func updateDisplayWaveform(_ waveform: Waveform) {
		guard self.displayWaveform != waveform else {
			return
		}
		
		displayWaveform = waveform
	}
}

extension WaveformViewCocoa: CALayerDelegate {
	public func action(for layer: CALayer, forKey event: String) -> CAAction? {
		if event == "bounds" || event == "position" {
			return didChangeFrame || inLiveResize ? NSNull() : nil
		}
		
		return nil
	}
}

public struct WaveformView: NSViewRepresentable {
	public var colorLUT: [CGColor]
	public var waveform: Waveform?
	public var spacing: Float = 1
	public var changeDuration: TimeInterval = 0.2
	public var resample: ResamplingWaveform.Resampler? = nil

	public init(
		colorLUT: [CGColor],
		waveform: Waveform?,
		spacing: Float = 1,
		changeDuration: TimeInterval = 0.2,
		resample: ResamplingWaveform.Resampler? = nil
	) {
		self.colorLUT = colorLUT
		self.waveform = waveform
		self.spacing = spacing
		self.changeDuration = changeDuration
		self.resample = resample
	}

	public func makeNSView(context: NSViewRepresentableContext<WaveformView>) -> WaveformViewCocoa {
		let nsView = WaveformViewCocoa(colorLUT: colorLUT)
		nsView.waveform = waveform
		nsView.spacing = CGFloat(spacing)
		return nsView
	}

	public func updateNSView(_ nsView: WaveformViewCocoa, context: NSViewRepresentableContext<WaveformView>) {

		nsView.colorLUT = colorLUT
		nsView.waveform = waveform
		nsView.spacing = CGFloat(spacing)
		nsView.changeDuration = CFTimeInterval(changeDuration)
		nsView.resample = resample
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
					waveform: waveform(shift: shift),
					resample: ResamplingWaveform.resampleNearest
				)
			}
		}
	}

	static var previews: some View {
		MockView()
	}
}
