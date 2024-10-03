//
//  Corg2App.swift
//  Corg2
//
//  Created by Felix Haag on 02.10.24.
//

import SwiftUI
import SwiftData

@main
struct Corg2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteCalendar.self,
            CalendarEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CalendarManager())
        }
        .modelContainer(sharedModelContainer)
    }
}
