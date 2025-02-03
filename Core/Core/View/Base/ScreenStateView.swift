//
//  ScreenStateView.swift
//  Core
//
//  Created by Muhammad Tayyab  Akram on 1/30/25.
//

import SwiftUI
import Theme

public struct ScreenStateView: View {
    public enum StateType {
        case noInternet
        case serverError
    }
    
    public struct Button {
        let type: UnitButtonType
        let action: () -> Void
        
        public static func reload(
            _ action: @escaping () -> Void
        ) -> Button {
            return Button(type: .reload, action: action)
        }
    }
    
    private let title: String
    private let description: String
    private let image: Image
    private let button: Button?
    
    public init(
        title: String,
        description: String,
        image: Image,
        button: Button? = nil
    ) {
        self.title = title
        self.description = description
        self.image = image
        self.button = button
    }
    
    public init(
        _ stateType: StateType,
        button: Button? = nil
    ) {
        switch stateType {
        case .noInternet:
            self.init(
                title: CoreLocalization.Error.Internet.noInternetTitle,
                description: CoreLocalization.Error.Internet.noInternetDescription,
                image: CoreAssets.noInternet.swiftUIImage,
                button: button
            )
        case .serverError:
            self.init(
                title: CoreLocalization.Error.Server.genericTitle,
                description: CoreLocalization.Error.Server.genericDescription,
                image: CoreAssets.serverError.swiftUIImage,
                button: button
            )
        }
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 62, maxHeight: 62)
            
            Text(title)
                .font(Theme.Fonts.titleLarge)
                .foregroundColor(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(Theme.Fonts.bodyLarge)
                .foregroundColor(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            if let button {
                UnitButtonView(
                    type: button.type,
                    action: button.action
                )
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.all, 24)
        .background(
            Theme.Colors.background
        )
    }
}

#if DEBUG
#Preview("No Internet") {
    ScreenStateView(.noInternet, button: .reload {})
}

#Preview("Server Error") {
    ScreenStateView(.serverError, button: .reload {})
}

#Preview("Custom State") {
    ScreenStateView(
        title: "Custom State",
        description: "This is a custom state description.",
        image: Image(systemName: "cloud.circle.fill")
    )
}
#endif
