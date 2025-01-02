//
//  NYCHAppV1_2App.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/7/24.
//

import SwiftUI
import SwiftData

@main
struct NYCHAppV1_2App: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: CustomerInformation.self)
            print("SwiftData container initialized successfully")
        } catch {
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
