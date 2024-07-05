//
//  CourseAccessMessageView.swift
//  Core
//
//  Created by Saeed Bashir on 6/28/24.
//

import Foundation
import SwiftUI
import Theme

public struct CourseAccessMessageView: View {
    public let startDate: Date?
    public let endDate: Date?
    public let auditAccessExpires: Date?
    public let startDisplay: Date?
    public let startType: DisplayStartType?
    public let font: Font
    public let textColor: Color
    public let dateStyle: DateStringStyle
    
    public init(
        startDate: Date?,
        endDate: Date?,
        auditAccessExpires: Date?,
        startDisplay: Date?,
        startType: DisplayStartType?,
        font: Font = Theme.Fonts.labelMedium,
        textColor: Color = Theme.Colors.textSecondaryLight,
        dateStyle: DateStringStyle = .startDDMonthYear
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.auditAccessExpires = auditAccessExpires
        self.startDisplay = startDisplay
        self.startType = startType
        self.font = font
        self.textColor = textColor
        self.dateStyle = dateStyle
    }
    
    public var body: some View {
        Text(
            CourseItem.nextRelevantDateMessage(
                startDate: startDate,
                endDate: endDate,
                auditAccessExpires: auditAccessExpires,
                startDisplay: startDisplay,
                startType: startType,
                dateStyle: dateStyle
            ) ?? ""
        )
        .font(font)
        .foregroundStyle(textColor)
    }
}
