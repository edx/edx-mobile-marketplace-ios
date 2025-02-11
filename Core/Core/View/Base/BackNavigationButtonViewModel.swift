//
//  BackNavigationButtonViewModel.swift
//  Core
//
//  Created by Vadim Kuznetsov on 3.04.24.
//

import Swinject
import UIKit
import OEXFoundation

@MainActor
public protocol BackNavigationProtocol {
    func getBackMenuItems() -> [BackNavigationMenuItem]
    func navigateTo(item: BackNavigationMenuItem)
}

// Mark - For testing and SwiftUI preview
#if DEBUG
final class BackNavigationMock: BackNavigationProtocol {
    func getBackMenuItems() -> [BackNavigationMenuItem] {
        return [
            BackNavigationMenuItem(id: 0, title: "Home")
        ]
    }
    
    func navigateTo(item: BackNavigationMenuItem) { }
}
#endif

public struct BackNavigationMenuItem: Identifiable {
    public var id: Int
    public var title: String
    
    public init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}

@MainActor
class BackNavigationButtonViewModel: ObservableObject {
    private let helper: BackNavigationProtocol
    @Published var items: [BackNavigationMenuItem] = []
    
    static var defaultBackNavigation: BackNavigationProtocol {
        #if DEBUG
        if AppEnvironment.isPreview {
            return BackNavigationMock()
        }
        #endif
        
        return Container.shared.resolve(BackNavigationProtocol.self)!
    }
    
    init(backNavigation: BackNavigationProtocol = defaultBackNavigation) {
        self.helper = backNavigation
    }
    
    func loadItems() {
        self.items = helper.getBackMenuItems()
    }
    
    func navigateTo(item: BackNavigationMenuItem) {
        helper.navigateTo(item: item)
    }
}
