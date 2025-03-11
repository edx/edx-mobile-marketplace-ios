//
//  IAPManagerProtocol.swift
//  Core
//
//  Created by Vadim Kuznetsov on 11.03.25.
//

import OEXFoundation
public protocol IAPManagerProtocol {
    var iapService: (any IAPServiceProtocol)? { get }
    func configuration(for primaryCourse: PrimaryCourse) -> IAPConfiguration
    func dashboardPrimaryCardButton(configuration: IAPConfiguration)
}
