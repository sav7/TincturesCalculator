import SwiftUI

@main
struct DistillerCalcApp: App {
    
    @StateObject private var themeSettings = ThemeSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeSettings)
                .preferredColorScheme(themeSettings.effectiveColorScheme)
        }
    }
}
