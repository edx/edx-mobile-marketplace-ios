// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum NotificationsLocalization {
  /// Notifications
  public static let notifications = NotificationsLocalization.tr("Localizable", "NOTIFICATIONS", fallback: "Notifications")
  public enum Settings {
    /// Notifications for course discussions you post, comment, or follow.
    public static let preferenceDescription = NotificationsLocalization.tr("Localizable", "SETTINGS.PREFERENCE_DESCRIPTION", fallback: "Notifications for course discussions you post, comment, or follow.")
    /// Discussions Activity
    public static let preferenceTitle = NotificationsLocalization.tr("Localizable", "SETTINGS.PREFERENCE_TITLE", fallback: "Discussions Activity")
    /// Localizable.strings
    ///   Notifications
    /// 
    ///   Created by Saeed Bashir on 11.12.2024.
    public static let title = NotificationsLocalization.tr("Localizable", "SETTINGS.TITLE", fallback: "Push Notifications")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension NotificationsLocalization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
