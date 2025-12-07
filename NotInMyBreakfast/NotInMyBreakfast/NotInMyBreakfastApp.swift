//
//  NotInMyBreakfastApp.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/16/25.
//

import SwiftUI

@main
struct NotInMyBreakfastApp: App {
    @StateObject private var blacklistStore = BlacklistStore()
    @StateObject private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(blacklistStore)
                .environmentObject(historyStore)
        }
    }
}

