//
//  Animation.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 27.12.20.
//

import Foundation
import SwiftUI

extension Animation {
	public static var instant: Animation { .linear(duration: 0) }
}

extension View {
	/// Animate ONLY IF the identity changes. Sort of like the opposite of animation(:, value:)
	public func animation<E : Equatable>(_ animation: Animation, identity: E) -> some View {
		self.animation(nil, value: identity).animation(animation)
	}
}
