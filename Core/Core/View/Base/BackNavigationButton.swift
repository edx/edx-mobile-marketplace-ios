//
//  BackNavigationButton.swift
//  Core
//
//  Created by Vadim Kuznetsov on 3.04.24.
//

import SwiftUI
import Theme

class BackButton: UIButton {
    var directionalInsets: NSDirectionalEdgeInsets = .zero {
        didSet {
            contentEdgeInsets = resolvedInsets
        }
    }
    
    private var resolvedInsets: UIEdgeInsets {
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            return UIEdgeInsets(
                top: directionalInsets.top,
                left: directionalInsets.trailing,
                bottom: directionalInsets.bottom,
                right: directionalInsets.leading
            )
        }
        
        return UIEdgeInsets(
            top: directionalInsets.top,
            left: directionalInsets.leading,
            bottom: directionalInsets.bottom,
            right: directionalInsets.trailing
        )
    }
    
    override func menuAttachmentPoint(for configuration: UIContextMenuConfiguration) -> CGPoint {
        return .zero
    }
}

public struct BackNavigationButtonRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BackNavigationButtonViewModel
    var action: (() -> Void)?
    var insets: EdgeInsets?
    var color: Color

    public func makeUIView(context: Context) -> UIButton {
        let button = BackButton(type: .system)
        let image = CoreAssets.arrowLeft.image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonAction), for: .touchUpInside)
        button.accessibilityIdentifier = "back_button"
        return button
    }

    public func updateUIView(_ button: UIButton, context: Context) {
        guard let button = button as? BackButton else { return }
        
        button.tintColor = UIColor(color)
        
        if let insets {
            button.directionalInsets = NSDirectionalEdgeInsets(insets)
        } else {
            button.directionalInsets = .zero
        }
        
        var actions: [UIAction] = []
        for item in viewModel.items {
            let action = UIAction(title: item.title) {[weak viewModel] _ in
                viewModel?.navigateTo(item: item)
            }
            actions.append(action)
        }
        button.menu = UIMenu(title: "", children: actions)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    public class Coordinator: NSObject {
        var action: (() -> Void)?
        init(action: (() -> Void)?) {
            self.action = action
        }
        
        @objc func buttonAction() {
            action?()
        }
    }
}

public struct BackNavigationButton: View {
    @StateObject var viewModel = BackNavigationButtonViewModel()
    private let color: Color
    private let insets: EdgeInsets?
    private let action: (() -> Void)?
    
    public init(
        color: Color = Theme.Colors.accentXColor,
        insets: EdgeInsets? = nil,
        action: (() -> Void)? = nil
    ) {
        self.color = color
        self.insets = insets
        self.action = action
    }
    
    public var body: some View {
        BackNavigationButtonRepresentable(
            viewModel: viewModel,
            action: action,
            insets: insets,
            color: color
        )
        .accessibilityIdentifier("back_button")
        .accessibilityLabel(CoreLocalization.back)
        .onAppear {
            viewModel.loadItems()
        }
        
    }
}
#if DEBUG
struct BackNavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        BackNavigationButton()
    }
}
#endif
