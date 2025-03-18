//
//  OnPressButtonStyle.swift
//  Core
//
//  Created by Muhammad Tayyab Akram on 3/10/25.
//

import SwiftUI

public struct OnPressButtonStyle: ButtonStyle {
    private let onPress: (() -> Void)

    public init(onPress: @escaping () -> Void) {
        self.onPress = onPress
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                if newValue {
                    onPress()
                }
            }
    }
}
