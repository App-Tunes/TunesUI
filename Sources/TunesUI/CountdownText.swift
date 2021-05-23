//
//  CountdownText.swift
//  TunesUI
//
//  Created by Lukas Tenbrink on 23.05.21.
//

import SwiftUI

import SwiftUI

extension TimeInterval {
	var humanReadableText: String {
		let totalSeconds = Int(rounded())
		let hours: Int = Int(totalSeconds / 3600)
		
		let minutes: Int = Int(totalSeconds % 3600 / 60)
		let seconds: Int = Int((totalSeconds % 3600) % 60)

		if hours > 0 {
			return String(format: "%i:%02i:%02i", hours, minutes, seconds)
		} else {
			return String(format: "%i:%02i", minutes, seconds)
		}
	}
}

struct CountdownText: View {
	var referenceDate: Date
	@State var currentDate: Date
	
	var advancesAutomatically: Bool = true
	
	var maxDate: Date? = nil
	var minDate: Date? = nil

	var timer: Timer? {
		advancesAutomatically ? Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			update()
		} : nil
	}
	
	func update() {
		self.currentDate = Date()
		
		if let minDate = minDate {
			self.currentDate = max(minDate, currentDate)
		}
		if let maxDate = maxDate {
			self.currentDate = min(maxDate, currentDate)
		}
	}

	var body: some View {
		Text(abs(referenceDate.timeIntervalSince(currentDate)).humanReadableText)
			.onAppear(perform: {
				let _ = self.timer
			})
			.font(.system(.body, design: .monospaced))
	}
}

struct CountdownText_Previews: PreviewProvider {
	static var previews: some View {
		let end = Date().advanced(by: 10)
		return CountdownText(
			referenceDate: end,
			currentDate: Date(),
			advancesAutomatically: true,
			maxDate: end
		)
			.frame(width: 60, height: 15)
	}
}
