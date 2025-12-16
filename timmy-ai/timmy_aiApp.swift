//
//  timmy_aiApp.swift
//  timmy-ai
//
//  Created by Roman Sheydvasser on 12/16/25.
//

import SwiftUI

@main
struct timmy_aiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Timmy", systemImage: "message") {
            Button("Toggle Chat") {
                appDelegate.toggleChat()
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
