//
//  OutputDeviceSelector.swift
//  ElevenTunes
//
//  Created by Lukas Tenbrink on 20.03.21.
//

import SwiftUI

public struct AudioProviderView<Provider: AudioDeviceProvider>: View {
	@ObservedObject public var provider: Provider
	@ObservedObject public var current: ObservableBinding<Provider.Option?>
	
	@State private var pressOption: Provider.Option?
	@State private var hoverOption: Provider.Option?

	public init(provider: Provider, current: ObservableBinding<Provider.Option?>) {
		self.provider = provider
		self.current = current
	}
	
	public func optionView(_ option: Provider.Option) -> some View {
		HStack {
			Text(option.icon)
				.frame(width: 25, alignment: .center)
			Text(option.name ?? "Unknown Device")
				.frame(minWidth: 50, maxWidth: .infinity, alignment: .leading)
			
			Text("􀆅").foregroundColor(Color.white.opacity(
				current.value == option ? 1 :
				hoverOption == option ? 0.2 :
				0
			))
				.frame(width: 25, alignment: .leading)
		}.frame(maxWidth: .infinity)
	}
	
	public func backgroundOpacity(_ option: Provider.Option) -> Double? {
		pressOption == option ? 0.4 :
		hoverOption == option ? 0.2 :
			nil
	}

	public var body: some View {
		VStack {
			HStack {
				provider.icon
					.resizable()
					.foregroundColor(provider.color)
					.frame(width: 14, height: 14)

				if let device = current.value {
					Text(device.name ?? "Unknown Device").bold()
						.padding(.trailing)
						.frame(minWidth: 50, maxWidth: .infinity, alignment: .leading)
					
					ExtendedAudioDeviceView(device: device)
						.frame(width: 150)
				}
				else {
					Text("None Selected").bold()
						.foregroundColor(.secondary)
						.padding(.trailing)
						.frame(minWidth: 50, maxWidth: .infinity, alignment: .leading)

					HStack(spacing: 8) {
						Spacer()
						
						Slider(value: .constant(0), in: 0...1)
							.frame(maxWidth: 100)

						AudioUI.imageForVolume(0)
							.frame(width: 25, alignment: .leading)
					}
						.frame(width: 150)
						.disabled(true)
				}
			}
				.frame(height: 20)
				.padding(.horizontal)
				.padding(.vertical, 4)

			VStack(alignment: .leading, spacing: 0) {
				ForEach(provider.options, id: \.id) { option in
					optionView(option)
						.padding(.horizontal)
						.padding(.vertical, 8)
						.background(backgroundOpacity(option).map(Color.gray.opacity))
						.onHover { over in
							self.hoverOption = over ? option : nil
						}
						.onTapGesture {
							if self.current.value == option {
								self.current.value = nil
							}
							else {
								self.current.value = option
							}
						}
						.onLongPressGesture(pressing: { isDown in
							self.pressOption = isDown ? option : nil
						}) {}
				}
			}
		}
	}
}
