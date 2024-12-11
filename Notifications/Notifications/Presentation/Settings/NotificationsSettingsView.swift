//
//  NotificationsSettingsView.swift
//  Notifications
//
//  Created by Saeed Bashir on 12/11/24.
//

import SwiftUI
import Theme

public struct NotificationsSettingsView: View {
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack(alignment: .center) {
                    Text("Notificaion settings view")
                }
                .hideNavigationBar(true)
                .navigationBarBackButtonHidden(true)
                .navigationTitle(NotificationsLocalization.Notifications.Settings.title)
            }
            
        }
        .background(
            Theme.Colors.background
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.all, edges: .horizontal)
    }
}
