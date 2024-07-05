//
//  Discovery.swift
//  Core
//
//  Created by  Stepanok Ivan on 16.09.2022.
//

import Foundation

public struct CourseItem: Hashable {
    public let name: String
    public let org: String
    public let shortDescription: String
    public let imageURL: String
    public let hasAccess: Bool
    public let courseStart: Date?
    public let courseEnd: Date?
    public let enrollmentStart: Date?
    public let enrollmentEnd: Date?
    public let courseID: String
    public let numPages: Int
    public let coursesCount: Int
    public let sku: String
    public let dynamicUpgradeDeadline: Date?
    public let mode: DataLayer.Mode
    public let isSelfPaced: Bool?
    public let courseRawImage: String?
    public let coursewareAccess: CoursewareAccess?
    public let progressEarned: Int
    public let progressPossible: Int
    public let auditAccessExpires: Date?
    public let startDisplay: Date?
    public let startType: DisplayStartType?
    
    public init(name: String,
                org: String,
                shortDescription: String,
                imageURL: String,
                hasAccess: Bool,
                courseStart: Date?,
                courseEnd: Date?,
                enrollmentStart: Date?,
                enrollmentEnd: Date?,
                courseID: String,
                numPages: Int,
                coursesCount: Int,
                sku: String = "",
                dynamicUpgradeDeadline: Date? = nil,
                mode: DataLayer.Mode = .audit,
                isSelfPaced: Bool?,
                courseRawImage: String?,
                coursewareAccess: CoursewareAccess?,
                progressEarned: Int,
                progressPossible: Int,
                auditAccessExpires: Date?,
                startDisplay: Date?,
                startType: DisplayStartType?
    ) {
        self.name = name
        self.org = org
        self.shortDescription = shortDescription
        self.imageURL = imageURL
        self.hasAccess = hasAccess
        self.courseStart = courseStart
        self.courseEnd = courseEnd
        self.enrollmentStart = enrollmentStart
        self.enrollmentEnd = enrollmentEnd
        self.courseID = courseID
        self.numPages = numPages
        self.coursesCount = coursesCount
        self.sku = sku
        self.dynamicUpgradeDeadline = dynamicUpgradeDeadline
        self.mode = mode
        self.isSelfPaced = isSelfPaced
        self.courseRawImage = courseRawImage
        self.coursewareAccess = coursewareAccess
        self.progressEarned = progressEarned
        self.progressPossible = progressPossible
        self.auditAccessExpires = auditAccessExpires
        self.startDisplay = startDisplay
        self.startType = startType
    }
}

extension CourseItem {
    public var isUpgradeable: Bool {
        guard let upgradeDeadline = dynamicUpgradeDeadline, mode == .audit else {
            return false
        }
        return !upgradeDeadline.isInPast()
        && !sku.isEmpty
        && courseStart?.isInPast() ?? false
    }
}

extension CourseItem {
    public static func nextRelevantDateMessage(
        startDate: Date?,
        endDate: Date?,
        auditAccessExpires: Date?,
        startDisplay: Date?,
        startType: DisplayStartType?,
        dateStyle: DateStringStyle) -> String? {
            
        if startDate?.isInPast() ?? false {
            if auditAccessExpires != nil {
                return formattedAuditExpires(dateStyle: dateStyle, auditAccessExpires: auditAccessExpires)
            }
            
            guard let endDate = endDate else {
                return nil
            }
            
            let formattedEndDate = endDate.stringValue(style: dateStyle)
            
            return endDate.isInPast() ? CoreLocalization.Course.ended(formattedEndDate) :
            CoreLocalization.Course.ending(formattedEndDate)
        } else {
            let formattedStartDate = startDate?.stringValue(style: dateStyle) ?? ""
            switch startType {
            case .string where startDisplay != nil:
                if startDisplay?.daysUntil() ?? 0 < 1 {
                    return CoreLocalization.Course.starting(startDate?.timeUntilDisplay() ?? "")
                } else {
                    return CoreLocalization.Course.starting(formattedStartDate)
                }
            case .timestamp where startDate != nil:
                return CoreLocalization.Course.starting(formattedStartDate)
            case .empty where startDate != nil:
                return CoreLocalization.Course.starting(formattedStartDate)
            default:
                return CoreLocalization.Course.starting(CoreLocalization.Course.soon)
            }
        }
    }
    
    static private func formattedAuditExpires(
        dateStyle: DateStringStyle,
        auditAccessExpires: Date?
    ) -> String {
        guard let auditExpiry = auditAccessExpires as Date? else { return "" }

        let formattedExpiryDate = auditExpiry.stringValue(style: dateStyle)
        let timeSpan = 7 // show number of days when less than a week
        
        if auditExpiry.isInPast() {
            let days = auditExpiry.daysAgo()
            if days < 1 {
                return CoreLocalization.Course.Audit.expiredAgo(auditExpiry.timeAgoDisplay())
            }
            
            if days <= timeSpan {
                return CoreLocalization.Course.Audit.expiredDaysAgo(days)
            } else {
                return CoreLocalization.Course.Audit.expiredOn(formattedExpiryDate)
            }
        } else {
            let days = auditExpiry.daysUntil()
            if days < 1 {
                return CoreLocalization.Course.Audit.expiresIn(auditExpiry.timeUntilDisplay())
            }
            
            if days <= timeSpan {
                return CoreLocalization.Course.Audit.expiresIn(days)
            } else {
                return CoreLocalization.Course.Audit.expiresOn(formattedExpiryDate)
            }
        }
    }
}
