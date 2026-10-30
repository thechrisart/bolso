import SwiftUI

/// Bolso para iPhone, iPad e Mac.
/// A interface é o mesmo app web (pasta Web), rodando dentro de um WKWebView.
@main
struct BolsoApp: App {
    var body: some Scene {
        WindowGroup {
            BolsoWebView()
                .ignoresSafeArea()
                .background(Color.appBackground)
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 820)
        .commands {
            // Remove "Novo" (o app tem uma janela só)
            CommandGroup(replacing: .newItem) {}
        }
        #endif
    }
}

extension Color {
    /// Mesmo fundo do cabeçalho do app web, em claro e escuro.
    static var appBackground: Color {
        #if os(iOS)
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
            ? UIColor(red: 0.090, green: 0.098, blue: 0.118, alpha: 1)
            : .white })
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
}
