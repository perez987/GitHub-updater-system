import SwiftUI

@main
struct APP: App {
 

    var body: some Scene {
        }
        .windowResizability(.contentSize)
        
        .commands {
            CommandGroup(after: .appInfo) {
                // Settings to check for updates
                Button(NSLocalizedString("Check for Updates…", comment: "Menu item to check for app updates"),
                       systemImage: "arrow.triangle.2.circlepath") {
                    GitHubUpdateChecker.shared.checkForUpdates(userInitiated: true)
                }
                       .keyboardShortcut("u", modifiers: [.command])
            }            
        }
}
