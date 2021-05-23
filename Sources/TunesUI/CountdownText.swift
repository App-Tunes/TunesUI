//
//  CountdownText.swift
//  TunesUI
//
//  Created by Lukas Tenbrink on 23.05.21.
//

import SwiftUI

extension TimeInterval {
	public var humanReadableText: String {
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

public struct CountdownText: View {
	public var referenceDate: Date
	@State public var currentDate: Date
	
	public var advancesAutomatically: Bool = true
	
	public var maxDate: Date? = nil
	public var minDate: Date? = nil

	public var timer: Timer? {
		advancesAutomatically ? Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			update()
		} : nil
	}
	
	public init(to referenceDate: Date, currentDate: Date = Date(), advancesAutomatically: Bool = true, maxDate: Date? = nil, minDate: Date? = nil) {
		self.referenceDate = referenceDate
		self._currentDate = State(initialValue: currentDate)
		
		self.advancesAutomatically = advancesAutomatically
		
		self.maxDate = maxDate
		self.minDate = minDate
	}
	
	public func update() {
		self.currentDate = Date()
		
		if let minDate = minDate {
			self.currentDate = max(minDate, currentDate)
		}
		if let maxDate = maxDate {
			self.currentDate = min(maxDate, currentDate)
		}
	}

	public var body: some View {
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
		return CountdownText(to: end, maxDate: end)
			.frame(width: 60, height: 15)
	}
}
