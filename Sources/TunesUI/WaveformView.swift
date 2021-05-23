//
//  WaveformView.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 01.04.21.
//

import SwiftUI
import Combine

struct WaveformView: View {
	let data: [CGFloat]
	let color: [Color]

	var body: some View {
		let count = min(data.count, color.count)
		
		GeometryReader { geo in
			HStack(alignment: .bottom, spacing: 2) {
				ForEach(0..<count) { i in
					Rectangle()
						.foregroundColor(color[i])
						.frame(height: geo.size.height * max(0, min(1, data[i])), alignment: .bottom)
				}
				.frame(height: geo.size.height, alignment: .bottom)
			}
		}
			.drawingGroup()
			.id(count)
	}
}

struct ResamplingWaveformView_Previews: PreviewProvider {
	static var previews: some View {
		WaveformView(
			data: [1, 0.5, 0.3, 0],
			color: [Color.red, Color.blue, Color.red, Color.blue]
		)
			.frame(width: 500, height: 100)
	}
}
