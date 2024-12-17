//
//  NotificationsPersistence.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/13/24.
//

import CoreData
import Notifications

public class NotificationsPersistence: NotificationsPersistenceProtocol {
    private var context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
}
