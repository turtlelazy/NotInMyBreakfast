//
//  NotInMyBreakfastApp.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/16/25.
//

import SwiftUI

// Local BlacklistStore definition (kept here so the app has a compiled canonical store
// even if `ViewModels/BlacklistStore.swift` isn't yet added to the Xcode project).
final class BlacklistStore: ObservableObject {
    @Published var items: [String] = [] {
        didSet { save() }
    }

    private let defaultsKey = "blacklist_items_v1"

    init(defaults: [String] = ["Gelatin", "Peanuts", "Palm Oil"]) {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            self.items = decoded
        } else {
            self.items = defaults
            save()
        }
    }

    func add(_ ingredient: String) {
        let trimmed = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !items.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            items.append(trimmed)
        }
    }

    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }

    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}

@main
struct NotInMyBreakfastApp: App {
    @StateObject private var blacklistStore = BlacklistStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(blacklistStore)
        }
    }
}

