import SwiftUI


// Entry Point of the project
@main
struct WordTranslatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 300)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
