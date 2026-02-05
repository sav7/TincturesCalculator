import SwiftUI
import Combine

enum ThemeMode: String, Codable, CaseIterable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Тёмная"
}

class ThemeSettings: ObservableObject {
    
    @Published var theme: ThemeMode {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "themeMode")
        }
    }
    
    init() {
        let raw = UserDefaults.standard.string(forKey: "themeMode")
        self.theme = ThemeMode(rawValue: raw ?? "") ?? .system
        
        var effectiveColorScheme: ColorScheme? {
            switch theme {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }
}
