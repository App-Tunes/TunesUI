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
	public typealias Resampler = ([Float], Int) -> [Float]

	// Style
	public var colorLUT: [CGColor]? { didSet {
		if colorLUT != oldValue { needsLayout = true }
	} }
	public var spacing: CGFloat = 1 { didSet {
		if spacing != oldValue { needsLayout = true }
	} }
	@Published public var pixelsPerBar: CGFloat = 4

	// State
	@Published public var waveform: Waveform = .empty
	@Published public var resample: Resampler? = nil
	@Published public private(set) var desiredCount: Int = 0
	@Published public private(set) var sizeX: CGFloat = 0

	// Other
	private var sizeObserver: AnyCancellable?
	private var waveformObserver: AnyCancellable?

	private var suppressAnimationsDate: Date = .distantPast
	
	public private(set) var displayWaveform: Waveform = .empty {
		didSet { needsLayout = true }
	}

	public init(colorLUT: [CGColor]? = nil) {
		self.colorLUT = colorLUT
		super.init(frame: NSRect())

		wantsLayer = true
		layer!.contentsGravity = .bottom
		layer!.delegate = self
		layer!.actions = [
			kCAOnOrderIn: NSNull(),
			kCAOnOrderOut: NSNull(),
			"position": NSNull(),
			"bounds": NSNull(),
			"hidden": NSNull(),
		]
		
		sizeObserver = $sizeX
			.debounce(for: 0.1, scheduler: DispatchQueue.global(qos: .default))
			.combineLatest($pixelsPerBar)
			.map { Int($0.0 / $0.1) }
			.sink { [weak self] in
				self?.desiredCount = $0
			}
		setupObserver()
	}
	
	required public init?(coder: NSCoder) {
		self.colorLUT = nil
		super.init(coder: coder)
	}
	
	private func setupObserver() {
		waveformObserver?.cancel()
		waveformObserver = $waveform.combineLatest($desiredCount, $resample)
			.receive(on: RunLoop.main)
			.sink { [weak self] (waveform, desiredCount, resample) in
				guard let resample = resample else {
					self?.updateDisplayWaveform(waveform)
					return
				}
				
				let resampled: Waveform = waveform.applying { resample($0, desiredCount) }
				self?.updateDisplayWaveform(resampled)
			}
	}
	
	private func ensureSublayerCount<T: CALayer>(_ count: Int, of kind: T.Type) {
		let diffLayers = count - ((layer!.sublayers as? [T])?.count ?? 0)
		
		if diffLayers > 0 {
			let actions: [String: CAAction] = [
				kCAOnOrderIn: NSNull(),
				kCAOnOrderOut: NSNull(),
				"hidden": NSNull(),
			]
			
			layer!.sublayers = (layer!.sublayers ?? []) + (0 ..< diffLayers).map { _ in
				let layer = kind.init()
				layer.delegate = self
				layer.actions = actions
				return layer
			}
			suppressAnimationsDate = Date() + 0.1
		}
		else if diffLayers < 0 {
			layer!.sublayers?.removeLast(-diffLayers)
			suppressAnimationsDate = Date() + 0.1
		}
	}
	
	public override func layout() {
		setIfDifferent(self, \.sizeX, frame.size.width)

		// Multithreading safety, just in case
		let waveform = self.displayWaveform
		let colorLUT = self.colorLUT
		let barCount = waveform.count
		
		ensureSublayerCount(barCount, of: CAShapeLayer.self)
		
		let barWidth = frame.size.width / (CGFloat(barCount) * (1 + spacing))
		let barWidthHalf = barWidth / 2
		let stride = frame.size.width / CGFloat(barCount)
				
		for i in 0 ..< barCount {
			let center = (CGFloat(i) + 0.5) * stride
			let layer = layer!.sublayers![i]
			let loudnessValue = waveform.loudness[i]

			layer.frame = CGRect(
				x: center - barWidthHalf,
				y: frame.minY,
				width: barWidth,
				height: CGFloat(loudnessValue.isNormal ? max(0, min(1, loudnessValue)) : 0) * frame.height
			)
		}
		
		if let colorLUT = colorLUT {
			let lutCount = Float(colorLUT.count)

			for i in 0 ..< barCount {
				let layer = layer!.sublayers![i]
				
				let pitchValue = waveform.pitch[i]
				layer.backgroundColor = pitchValue.isNormal
					? colorLUT[min(colorLUT.count - 1, max(0, Int(pitchValue * lutCount)))]
					: .clear
			}
		}
		else {
			for i in 0 ..< barCount {
				let layer = layer!.sublayers![i]
				layer.backgroundColor = .white
			}
		}
		
		super.layout()
	}
	
	public func reset(suppressAnimationsUntil suppressAnimationsDate: Date? = nil) {
		// Cancel current queue
		waveformObserver?.cancel()

		// Cancel transitions
		for layer in (layer!.sublayers ?? []) {
			layer.removeAllAnimations()
		}
		
		if let suppressAnimationsDate = suppressAnimationsDate {
			self.suppressAnimationsDate = suppressAnimationsDate
		}
		
		// Avoid showing the old state. The new one might take a while yet tho
		updateDisplayWaveform(.zero(count: displayWaveform.count))
		waveform = .empty
		setupObserver()
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
		(Date() < suppressAnimationsDate || inLiveResize) ? NSNull() : nil
	}
}

public struct WaveformView: NSViewRepresentable {
	public var colorLUT: [CGColor]
	public var waveform: Waveform
	public var spacing: Float = 1
	public var resample: WaveformViewCocoa.Resampler? = nil
	public var suppressAnimationsDate: Date?

	public init(
		colorLUT: [CGColor],
		waveform: Waveform,
		spacing: Float = 1,
		resample: WaveformViewCocoa.Resampler? = nil,
		suppressAnimationsUntil suppressAnimationsDate: Date? = nil
	) {
		self.colorLUT = colorLUT
		self.waveform = waveform
		self.spacing = spacing
		self.resample = resample
		self.suppressAnimationsDate = suppressAnimationsDate
	}

	public func makeNSView(context: NSViewRepresentableContext<WaveformView>) -> WaveformViewCocoa {
		WaveformViewCocoa(colorLUT: colorLUT)
	}

	public func updateNSView(_ nsView: WaveformViewCocoa, context: NSViewRepresentableContext<WaveformView>) {
		nsView.colorLUT = colorLUT
		if suppressAnimationsDate != nil || context.transaction.disablesAnimations || context.transaction.animation == nil {
			nsView.reset(suppressAnimationsUntil: suppressAnimationsDate)
		}
		nsView.waveform = waveform
		nsView.spacing = CGFloat(spacing)
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
		@State var resetDate: Date = Date()

		var body: some View {
			VStack {
				Slider(value: $shift, in: 0...20)
				Button("Random") {
					shift = .random(in: 0...20)
					resetDate = Date()
				}
				
				WaveformView(
					colorLUT: Gradients.pitchCG,
					waveform: waveform(shift: shift),
					resample: Resample.nearest,
					suppressAnimationsUntil: resetDate + 0.2
				)
			}
		}
	}

	static var previews: some View {
		MockView()
	}
}
