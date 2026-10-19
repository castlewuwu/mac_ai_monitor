import SwiftUI

@main
struct AIMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 450, minHeight: 600)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 450, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}