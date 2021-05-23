//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 23.05.21.
//

import SwiftUI

public struct ResamplingWaveformView: View {
	public var colorLUT: [CGColor]
	@ObservedObject public var waveform: ResamplingWaveform
	public var spacing: Float = 1
	public var pixelsPerBar: CGFloat = 4
	public var changeDuration: TimeInterval = 0.2
	
	public init(
		colorLUT: [CGColor],
		waveform: ResamplingWaveform,
		spacing: Float = 1,
		pixelsPerBar: CGFloat = 4,
		changeDuration: TimeInterval = 0.2
	) {
		self.colorLUT = colorLUT
		self.waveform = waveform
		self.spacing = spacing
		self.pixelsPerBar = pixelsPerBar
		self.changeDuration = changeDuration
	}

	public var body: some View {
		WaveformView(
			colorLUT: colorLUT,
			waveform: waveform.waveform,
			spacing: spacing,
			changeDuration: changeDuration
		)
			.onGeoChange { geo in
				waveform.updateSamples(Int(geo.size.width / pixelsPerBar))
			}
	}
}

struct ResamplingWaveformView_Previews: PreviewProvider {
	static var previews: some View {
		ResamplingWaveformView(
			colorLUT: Gradients.pitchCG,
			waveform: ResamplingWaveform.constant(WaveformView_Previews.waveform(), resample: ResamplingWaveform.resampleNearest)
		)
			.frame(minWidth: 100, minHeight: 30)
	}
}
