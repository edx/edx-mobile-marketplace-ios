//
//  LaunchChatViewModel.swift
//  Core
//
//  Created by Anton Yarmolenka on 10/10/2024.
//

import Foundation
import Swinject

class LaunchChatViewModel: ObservableObject {
    private var router: BaseRouter
    private let connectivity: ConnectivityProtocol
    
    init(router: BaseRouter, connectivity: ConnectivityProtocol) {
        self.router = router
        self.connectivity = connectivity
    }
    
    public var showChatIcon: Bool {
        guard let config = Container.shared.resolve(ConfigProtocol.self) else { return false }
        return config.liveChat.enabled && connectivity.isInternetAvaliable
    }
    
    @MainActor
    func showLiveChat(animated: Bool) {
        router.showLiveChat(animated: animated)
    }
}
