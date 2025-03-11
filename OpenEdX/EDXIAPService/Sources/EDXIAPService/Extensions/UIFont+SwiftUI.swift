//
//  UIFont+SwiftUI.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//
import SwiftUI

extension UIFont {
    nonisolated(unsafe) static var isFontsLoaded: Bool = false
    
    static func loadFontsIfNeeded() {
        guard !isFontsLoaded,
              let url = Bundle.module.url(forResource: "fonts_file", withExtension: "ttf")
        else { return }
        isFontsLoaded = true
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
    
    static func custom(_ name: FontName, size: CGFloat) -> UIFont {
        loadFontsIfNeeded()
        guard let font = UIFont(name: name.rawValue, size: size) else {
            assertionFailure("UIFont with name `\(name.rawValue)` doesn't exist")
            return UIFont()
        }
        return font
    }
    
    func swiftUI() -> Font {
        .custom(self.fontName, size: self.pointSize)
    }
}
