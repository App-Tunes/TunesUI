//
//  File.swift
//  
//
//  Created by Lukas Tenbrink on 23.05.21.
//

import SwiftUI

public struct ResamplingWaveformView: View {
	public var gradient: [Color]
	@ObservedObject public var waveform: ResamplingWaveform

	public var body: some View {
		WaveformView(
			data: waveform.loudness.map { CGFloat($0) },
			color: waveform.pitch.map {
				$0.isFinite ? gradient[Int(round(max(0, min(1, $0)) * 255))] : .white
			}
		)
			.onGeoChange { geo in
				waveform.updateSamples(Int(geo.size.width / 4))
			}
	}
}

struct ResamplingWaveformView_Previews: PreviewProvider {
	static func waveform() -> Waveform {
		Waveform(
			loudness: (0...80).map {
				(sin(Float($0) / 3) + 1) / 2
			},
			pitch: (0...80).map {
				(sin(Float($0) / 2) + 1) / 2
			}
		)
	}

	static var previews: some View {
		ResamplingWaveformView(
			gradient: (0...255).map {
				Color(red: Double($0) / 255, green: 0, blue: 0)
			},
			waveform: ResamplingWaveform.constant(waveform(), resample: ResamplingWaveform.resampleNearest)
		)
			.frame(width: 500, height: 100)
	}
}