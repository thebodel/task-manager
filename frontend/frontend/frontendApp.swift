//
//  frontendApp.swift
//  frontend
//
//  Created by Bohdan on 03/04/2026.
//

import SwiftUI

@main
struct frontendApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 560)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
