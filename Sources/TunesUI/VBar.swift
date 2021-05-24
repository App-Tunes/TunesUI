//
//  SwiftUIView.swift
//  
//
//  Created by Lukas Tenbrink on 24.05.21.
//

import SwiftUI

public struct VBar : Shape {
	public var position: CGFloat

	public func path(in rect: CGRect) -> Path {
		var path = Path()

		path.move(to: .init(x: rect.size.width * position, y: rect.size.height))
		path.addLine(to: .init(x: rect.size.width * position, y: 0))

		return path
	}

	public var animatableData: CGFloat {
		get { return position }
		set { position = newValue }
	}
}

struct VBar_Previews: PreviewProvider {
    static var previews: some View {
		VBar(position: 0.5)
    }
}
