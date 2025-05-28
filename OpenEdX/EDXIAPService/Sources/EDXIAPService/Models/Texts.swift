//
//  Texts.swift
//  EDXIAPService
//
//  Created by Vadim Kuznetsov on 4.03.25.
//

enum Texts {
    static let ok = "Ok"
    static let cancel = "Cancel"
    static let close = "Close"
    enum Button {
        static let upgrade = "Upgrade to access more features"
    }
    enum Restore {
        static let inprogressText =  "Checking purchases..."
    }
    enum SnackBar {
        static let title = "Course upgraded"
        static let successMessage = "Thank you for your purchase. Enjoy full access to your course!"
    }
    enum UpgradeInfo {
        static let optionFirst = "Earn a certificate of completion to showcase on your resume"
        static let optionSecond = "Unlock access to all course activities, including graded assignments"
        static let optionThird = "Full access to course content and course material even after the course ends"
        static let unlockingText = "Unlocking "
        static let unlockingFullAccess = "full access "
        static let unlockingToCourse = "to your course"
        static let title = "Upgrade"
        
        enum Button {
            static let upgradeNow = "Upgrade now for"
            static let findCourse = "Find a new course"
        }
    }
    enum CourseUpgrade {
        enum SendEmail {
            static let supportEmailSubject = "Error upgrading course in app"
            static let emailNotSetupTitle = "Email not set up"
            static let cannotSendEmail = "Cannot send email. It seems your email client is not set up."
        }
        enum FailureAlert {
            static let paymentNotProcessed = """
                Your payment could not be processed at this time. Please try again. For additional help, \
                reach out to Support.
                """
            static let courseNotFound = """
                The course you are looking to upgrade could not be found. Please try your upgrade again. \
                If this error continues, contact Support.
                """
            static let authenticationErrorMessage = """
                Your account could not be authenticated. Try signing out and signing back into the app. \
                If this error continues, please contact Support.
                """
            static let courseAlreadyPaid = """
                The course you are looking to upgrade has already been paid for. For additional help, reach \
                out to Support.
                """
            static let courseNotFullfilled = """
                Something happened when we tried to update your course experience. If this error continues, \
                reach out to Support for help.
                """
            static let priceFetchError = "Try again"
            static let priceFetchErrorMessage = """
                Your request could not be completed at this time. If this error continues, please reach out to Support.
                """
            static let alertTitle = "An error occurred"
            static let refreshToRetry = "Refresh to retry"
            static let getHelp = "Get help"
        }
        enum SuccessAlert {
            static let silentAlertRefresh = "Refresh now"
            static let silentAlertContinue = "Continue without update"
            static let silentAlertTitle = "New experience available"
            static let silentAlertMessage = """
                An update is available to unlock a purchased course. To update, we need to quickly refresh your app. \
                If you choose not to update now, we’ll try again later.
                """
        }
        enum Restore {
            static let alertTitle = "Purchases have been successfully restored"
            static let alertMessage = """
                All purchases are up to date. If you’re not seeing your purchases restored, please try restarting \
                your app to refresh the experience.
                """
        }
    }
}
