//
//  Animation.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 27.12.20.
//

import Foundation
import SwiftUI

public extension Animation {
	static var instant: Animation { .linear(duration: 0) }
}

public extension View {
	/// Animate ONLY IF the identity changes. Sort of like the opposite of animation(:, value:)
	func animation<E : Equatable>(_ animation: Animation, identity: E) -> some View {
		self.animation(nil, value: identity).animation(animation)
	}
}
