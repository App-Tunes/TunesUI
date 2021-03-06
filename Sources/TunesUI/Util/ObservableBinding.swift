//
//  ObservableBinding.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 24.03.21.
//

import Combine

public class ObservableBinding<Value>: ObservableObject {
	private class Constant: ObservableObject {
		@Published var value: Value
		init(_ value: Value) { self.value = value }
	}
	
	private var observation: AnyCancellable?
	
	public let get: () -> Value
	public let set: (Value) -> Void
	
	public init<T: ObservableObject>(_ object: T, value: ReferenceWritableKeyPath<T, Value>) {
		get = { object[keyPath: value] }
		set = { object[keyPath: value] = $0 }
		observation = object.objectWillChange.sink { [weak self] _ in
			self?.objectWillChange.send()
		}
	}
	
	public static func constant(_ value: Value) -> ObservableBinding {
		.init(Constant(value), value: \.value)
	}

	public var value: Value {
		get { get() }
		set { set(newValue) }
	}
}
