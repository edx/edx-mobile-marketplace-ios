//
//  FullStoryAnalyticsService.swift
//  OpenEdX
//
//  Created by Saeed Bashir on 4/17/24.
//

import Foundation
import Core
import FullStory
import FirebaseCrashlytics

class FullStoryAnalyticsService: NSObject, AnalyticsService, FSDelegate {
    
    var firebaseEnabled: Bool
    init(_ firebaseEnabled: Bool) {
        self.firebaseEnabled = firebaseEnabled
        super.init()
        FS.delegate = self
        FS.restart()
    }
    
    func identify(id: String, username: String?, email: String?) {
        FS.identify(id, userVars: ["displayName": id])
    }
    
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        FS.event(event.rawValue, properties: parameters ?? [:])
    }
    
    func logScreenEvent(_ event: Core.AnalyticsEvent, parameters: [String: Any]?) {
        FS.page(withName: event.rawValue, properties: parameters).start()
    }

    func fullstoryDidStartSession(_ sessionUrl: String) {
        if firebaseEnabled {
            Crashlytics.crashlytics().setCustomValue(
                sessionUrl,
                forKey: "fullstory_session_url"
            )
        }
    }
}
