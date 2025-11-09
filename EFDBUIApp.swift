import SwiftUI

@main
struct EFDBUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 900, height: 600)
        .commands {
            // Add standard Edit menu with Find support
            TextEditingCommands()
        }
    }
}

