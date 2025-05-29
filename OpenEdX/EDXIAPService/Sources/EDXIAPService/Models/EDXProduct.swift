//
//  EDXProduct.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 30.05.25.
//
import OEXFoundation

public struct EDXProduct: IAPProduct {
    public var id: String
    public var name: String
    public var screen: EDXScreen
    public init(id: String, name: String, screen: EDXScreen) {
        self.id = id
        self.name = name
        self.screen = screen
    }
}
