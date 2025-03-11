//
//  UIImage+SwiftUI.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import SwiftUI

extension UIImage {
    func swiftUI() -> SwiftUI.Image {
        Image(uiImage: self)
    }
    
    static func image(named: String) -> UIImage {
        guard let image = UIImage(named: named, in: .module, compatibleWith: nil) else {
            assertionFailure("Image with name `\(named)` doesn't exist")
            return UIImage()
        }
        return image
    }
}
