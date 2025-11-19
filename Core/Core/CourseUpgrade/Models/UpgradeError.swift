//
//  UpgradeError.swift
//  Core
//
//  Created by Vadim Kuznetsov on 22.05.24.
//

import StoreKit

public enum UpgradeError: Error, LocalizedError, Equatable {
    public static func == (lhs: UpgradeError, rhs: UpgradeError) -> Bool {
        lhs.errorString == rhs.errorString
    }
    
    case paymentsNotAvailable // device isn't allowed to make payments
    case paymentError(Error?) // unable to purchase a product
    case receiptNotAvailable(Error?) // unable to fetech inapp purchase receipt
    case verifyReceiptError(Error) // verify receipt API returns error
    case unverifiedCourseError(Error) // unverified course mode error
    case productNotExist // product not existed on app appstore
    case generalError(Error?) // general error
    
    var errorString: String {
        switch self {
        case .paymentError:
            return "payment"
        case .verifyReceiptError:
            return "execute"
        case .unverifiedCourseError:
            return "unverified"
        default:
            return CoreLocalization.CourseUpgrade.FailureAlert.paymentNotProcessed
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .paymentError:
            return CoreLocalization.CourseUpgrade.FailureAlert.paymentNotProcessed
        case .verifyReceiptError(let error), .unverifiedCourseError(let error):
            return executeErrorMessage(for: error)
        default:
            break
        }
        return nil
    }
    
    private func executeErrorMessage(for error: Error) -> String {
        switch error.errorCode {
        case 409:
            return CoreLocalization.CourseUpgrade.FailureAlert.courseAlreadyPaid
        case 402:
            return CoreLocalization.CourseUpgrade.FailureAlert.generalErrorMessage
        default:
            return CoreLocalization.CourseUpgrade.FailureAlert.courseNotFullfilled
        }
    }
    
    private var nestedError: Error? {
        switch self {
        case .receiptNotAvailable(let error):
            return error
        case .verifyReceiptError(let error):
            return error
        case .unverifiedCourseError(let error):
            return error
        case .generalError(let error):
            return error
        case .paymentError(let error):
            return error
        default:
            return nil
        }
    }
    
    public var formattedError: String {
        let unhandledError = "unhandledError"
        guard let error = nestedError else { return unhandledError }
        return "\(errorString)-\(error.errorCode)-\(error.errorMessage)"
    }
    
    public var isCancelled: Bool {
        switch self {
        case .paymentError(let error):
            if let error = error as? SKError, error.code == .paymentCancelled {
                return true
            }
        default:
            break
        }
        return false
    }
}
