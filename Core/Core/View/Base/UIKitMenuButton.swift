//
//  UIKitMenuButton.swift
//  Core
//
//  Created by Abid Bhatti on 06/03/26.
//

import UIKit
import SwiftUI

public struct UIKitMenuButton<Item>: UIViewRepresentable {
    public typealias TitleProvider = (Item) -> String
    public typealias ImageProvider = (Item) -> UIImage?
    public typealias AttributesProvider = (Item) -> UIMenuElement.Attributes
    public typealias StateProvider = (Item) -> UIMenuElement.State
    public typealias SelectionHandler = (Item) -> Void
    
    private let items: [Item]
    private let titleProvider: TitleProvider
    private let imageProvider: ImageProvider
    private let attributesProvider: AttributesProvider
    private let stateProvider: StateProvider
    private let onTap: () -> Void
    private let onSelect: SelectionHandler
    private let buttonImage: UIImage?
    private let tintColor: UIColor
    private let accessibilityIdentifier: String?
    
    public init(
        items: [Item],
        titleProvider: @escaping TitleProvider,
        imageProvider: @escaping ImageProvider = { _ in nil },
        attributesProvider: @escaping AttributesProvider = { _ in [] },
        stateProvider: @escaping StateProvider = { _ in .off },
        onTap: @escaping () -> Void = {},
        onSelect: @escaping SelectionHandler,
        buttonImage: UIImage?,
        tintColor: UIColor = .label,
        accessibilityIdentifier: String? = nil
    ) {
        self.items = items
        self.titleProvider = titleProvider
        self.imageProvider = imageProvider
        self.attributesProvider = attributesProvider
        self.stateProvider = stateProvider
        self.onTap = onTap
        self.onSelect = onSelect
        self.buttonImage = buttonImage
        self.tintColor = tintColor
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }
    
    public func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.showsMenuAsPrimaryAction = true
        button.contentHorizontalAlignment = .center
        button.tintColor = tintColor
        button.accessibilityIdentifier = accessibilityIdentifier
        
        if let buttonImage {
            button.setImage(buttonImage.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.didTapButton),
            for: .menuActionTriggered
        )
        
        return button
    }
    
    public func updateUIView(_ button: UIButton, context: Context) {
        button.tintColor = tintColor
        button.accessibilityIdentifier = accessibilityIdentifier
        
        if let buttonImage {
            button.setImage(buttonImage.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            button.setImage(nil, for: .normal)
        }
        
        button.menu = UIMenu(
            children: items.map { item in
                let action = UIAction(
                    title: titleProvider(item),
                    image: imageProvider(item)
                ) { _ in
                    onSelect(item)
                }
                action.attributes = attributesProvider(item)
                action.state = stateProvider(item)
                return action
            }
        )
    }
    
    public static func dismantleUIView(_ uiView: UIButton, coordinator: Coordinator) {
        uiView.removeTarget(
            coordinator,
            action: #selector(Coordinator.didTapButton),
            for: .menuActionTriggered)
        uiView.menu = nil
    }
    
    public final class Coordinator: NSObject {
        private let onTap: () -> Void
        
        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }
        
        @objc
        func didTapButton() {
            onTap()
        }
    }
}
