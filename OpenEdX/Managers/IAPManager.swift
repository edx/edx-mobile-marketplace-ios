//
//  IAPManager.swift
//  OpenEdX
//
//  Created by Anton Yarmolenka on 24/01/2025.
//

import Foundation
import EDXIAPService
import SwiftUI

class IAPManager: NSObject {
    private let iapService: EDXIAPService?
    
    init(iapService: EDXIAPService?) {
        self.iapService = iapService
    }
    
    func testView() -> any View {
        if let iapService = iapService {
            return iapService.someTestView()
        } else {
            return EmptyView()
        }
    }
    
}
