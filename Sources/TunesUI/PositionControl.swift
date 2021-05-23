//
//  PositionControl.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 03.04.21.
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

public struct PositionControl: View {
	public var currentTimeProvider: () -> TimeInterval?
	@State public var currentTime: TimeInterval? = nil
	public var duration: TimeInterval
	public var advancesAutomatically: Bool
	public var moveStepDuration: TimeInterval? = nil

	public var moveTo: (TimeInterval) -> Void
	public var moveBy: ((TimeInterval) -> Void)? = nil

	// 'free' mouse position vs 'stepped' are handled differently,
	// so 'stepped' is animated properly and the jump can be exact
	@State var mousePosition: TimeInterval? = nil
	@State var mousePositionSteps: Int? = nil
	@State var isDragging = false
	
	public init(
		currentTimeProvider: @escaping () -> TimeInterval?,
		currentTime: TimeInterval? = nil,
		duration: TimeInterval,
		advancesAutomatically: Bool,
		moveStepDuration: TimeInterval? = nil,

		moveTo: @escaping (TimeInterval) -> Void,
		moveBy: ((TimeInterval) -> Void)? = nil
	) {
		self.currentTimeProvider = currentTimeProvider
		self.currentTime = currentTime
		self.duration = duration
		self.advancesAutomatically = advancesAutomatically
		
		self.moveTo = moveTo
		self.moveBy = moveBy
	}
	
	public func updatePosition() {
		guard let currentTime = currentTimeProvider() else {
			return
		}
		
		withAnimation(.instant) {
			self.currentTime = currentTime
		}
		
		if advancesAutomatically {
			withAnimation(.linear(duration: duration - currentTime)) {
				self.currentTime = duration
			}
		}
	}
	
	public func click(at point: CGFloat) {
		let pointTime = TimeInterval(point) * duration

		if
			!NSEvent.modifierFlags.contains(.option),
			let moveStepDuration = moveStepDuration,
			let currentTime = currentTimeProvider()
		{
			let steps = Int(round((pointTime - currentTime) / moveStepDuration))
			if steps != 0 {
				moveBy?(TimeInterval(steps) * moveStepDuration)
			}
		}
		else {
			moveTo(max(0, min(duration, pointTime)))
		}
	}
	
	public func updateMousePosition(at point: CGFloat) {
		let pointTime = TimeInterval(point) * duration

		guard
			!NSEvent.modifierFlags.contains(.option),
			let moveStepDuration = moveStepDuration,
			let currentTime = currentTimeProvider()
		else {
			mousePosition = max(0, min(duration, pointTime))
			mousePositionSteps = nil
			return
		}
		
		mousePositionSteps = Int(round((pointTime - currentTime) / moveStepDuration))
		mousePosition = nil
		updatePosition()  // To start animating mouse too
	}
	
	public var body: some View {
		GeometryReader { geo in
			ZStack {
				let width = max(1, min(2, 3 - geo.size.height / 20)) + 0.5
				
				// Needed, otherwise we won't get hover... :|
				Rectangle().fill(Color.clear)
				
				if let currentTime = currentTime {
					VBar(position: CGFloat(currentTime) / CGFloat(duration))
						.stroke(lineWidth: width)
						.id("playerbar")
					
					if let mousePositionSteps = mousePositionSteps, let moveStepDuration = moveStepDuration {
						VBar(position: (CGFloat(currentTime) + CGFloat(mousePositionSteps) * CGFloat(moveStepDuration)) / CGFloat(duration))
							.stroke(lineWidth: width)
							.opacity(isDragging ? 1 : 0.5)
							.id("mousebar")
					}
				}
				
				if let mousePosition = mousePosition {
					VBar(position: CGFloat(mousePosition) / CGFloat(duration))
						.stroke(lineWidth: width)
						.opacity(isDragging ? 1 : 0.5)
						.id("mousebar")
				}
			}
			.contentShape(Rectangle())
			.gesture(
				DragGesture(minimumDistance: 0, coordinateSpace: .local)
					.onChanged { value in
						updateMousePosition(at: value.location.x / geo.size.width)
						isDragging = true
					}
					.onEnded { value in
						click(at: value.location.x / geo.size.width)
						isDragging = false
						mousePosition = nil
						mousePositionSteps = nil
					}
			)
			.onHoverLocation { location in
				updateMousePosition(at: location.x / geo.size.width)
			} onEnded: {
				mousePosition = nil
				mousePositionSteps = nil
			}
			.onAppear {
				updatePosition()
			}
		}
	}
}

//struct PositionControl_Previews: PreviewProvider {
//    static var previews: some View {
//        PositionControl()
//    }
//}
