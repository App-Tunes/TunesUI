//
//  VisualEffectView.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 01.01.21.
//

import SwiftUI
import AppKit

public struct VisualEffectView: NSViewRepresentable {
	public let material: NSVisualEffectView.Material
	public let blendingMode: NSVisualEffectView.BlendingMode
	public let isEmphasized: Bool
	
	public init(
		material: NSVisualEffectView.Material,
		blendingMode: NSVisualEffectView.BlendingMode,
		emphasized: Bool) {
		self.material = material
		self.blendingMode = blendingMode
		self.isEmphasized = emphasized
	}
	
	public func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		
		// Not certain how necessary this is
		view.autoresizingMask = [.width, .height]
		
		return view
	}
	
	public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		nsView.material = material
		nsView.blendingMode = blendingMode
		nsView.isEmphasized = isEmphasized
	}
}

extension View {
	public func visualEffectBackground(
		material: NSVisualEffectView.Material,
		blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
		emphasized: Bool = false
	) -> some View {
		background(
			VisualEffectView(
				material: material,
				blendingMode: blendingMode,
				emphasized: emphasized
			)
		)
	}
	
	public func visualEffectOnTop(
		material: NSVisualEffectView.Material,
		blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
		emphasized: Bool = false
	) -> some View {
		VisualEffectView(
			material: material,
			blendingMode: blendingMode,
			emphasized: emphasized
		)
		.background(self)
	}
}

struct VisualEffectView_Previews: PreviewProvider {
	static var previews: some View {
		// Doesn't work well somehow
		return ZStack {
			Rectangle()
				.fill(Color.blue)
			
			VisualEffectView(material: .underPageBackground, blendingMode: .withinWindow, emphasized: true)
			
			Image(systemName: "gift.circle.fill")
				.font(.system(size: 300))
				.foregroundColor(.red)
		}
	}
}
