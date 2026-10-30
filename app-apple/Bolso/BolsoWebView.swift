import SwiftUI
import WebKit
#if os(iOS)
import UIKit
#else
import AppKit
#endif

/// Endereço interno do app web. As páginas são servidas da pasta Web do pacote
/// por `LocalFileSchemeHandler`, com origem fixa `bolso://localhost`
/// (o login do Supabase fica guardado nessa origem).
enum WebApp {
    static let scheme = "bolso"
    static let startURL = URL(string: "bolso://localhost/index.html")!
}

/// Monta o WKWebView com o app web, o servidor de arquivos locais
/// e a ponte que recebe os PDFs e planilhas gerados pela página.
final class WebViewFactory: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    let webView: WKWebView

    override init() {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(LocalFileSchemeHandler(), forURLScheme: WebApp.scheme)
        config.websiteDataStore = .default()
        #if os(iOS)
        config.allowsInlineMediaPlayback = true
        #endif
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        // A página chama window.webkit.messageHandlers.bolsoSave.postMessage({name, data})
        config.userContentController.add(WeakMessageHandler(self), name: "bolsoSave")
        webView.navigationDelegate = self
        webView.uiDelegate = self
        #if os(iOS)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive
        #else
        webView.setValue(false, forKey: "drawsBackground")
        #endif
        if #available(iOS 16.4, macOS 13.3, *) {
            #if DEBUG
            webView.isInspectable = true
            #endif
        }
        webView.load(URLRequest(url: WebApp.startURL))
    }

    // MARK: Navegação

    /// Páginas do app abrem aqui dentro; qualquer outro link (política de privacidade,
    /// e-mail etc.) abre no navegador do sistema.
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url else { return decisionHandler(.cancel) }
        let isAppPage = url.scheme == WebApp.scheme || url.scheme == "about" || url.scheme == "blob" || url.scheme == "data"
        if isAppPage || action.targetFrame?.isMainFrame == false {
            decisionHandler(.allow)
        } else {
            openExternally(url)
            decisionHandler(.cancel)
        }
    }

    /// Links com target="_blank" chegam aqui: abre no navegador do sistema.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = action.request.url { openExternally(url) }
        return nil
    }

    /// Se o processo da página for encerrado pelo sistema (pouca memória), recarrega.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    private func openExternally(_ url: URL) {
        #if os(iOS)
        UIApplication.shared.open(url)
        #else
        NSWorkspace.shared.open(url)
        #endif
    }

    // MARK: Arquivos gerados (PDF / Excel)

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "bolsoSave",
              let body = message.body as? [String: Any],
              let rawName = body["name"] as? String,
              let base64 = body["data"] as? String,
              let data = Data(base64Encoded: base64) else { return }
        let name = rawName.replacingOccurrences(of: "/", with: "-")
        DispatchQueue.main.async { self.deliver(data, named: name) }
    }

    private func deliver(_ data: Data, named name: String) {
        #if os(iOS)
        // iPhone/iPad: grava num arquivo temporário e abre "Compartilhar"
        // (Salvar em Arquivos, enviar por e-mail, WhatsApp, AirDrop…)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do { try data.write(to: url, options: .atomic) } catch { return }
        let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popover = sheet.popoverPresentationController { // iPad
            popover.sourceView = webView
            popover.sourceRect = CGRect(x: webView.bounds.midX, y: webView.bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        topViewController()?.present(sheet, animated: true)
        #else
        // Mac: janela "Salvar como"
        let panel = NSSavePanel()
        panel.nameFieldStringValue = name
        panel.canCreateDirectories = true
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? data.write(to: url, options: .atomic)
        }
        #endif
    }

    #if os(iOS)
    private func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
        var top = scene?.windows.first { $0.isKeyWindow }?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
    #endif
}

/// Evita ciclo de referência entre o WKUserContentController e o WebViewFactory.
private final class WeakMessageHandler: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?
    init(_ target: WKScriptMessageHandler) { self.target = target }
    func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
        target?.userContentController(c, didReceive: m)
    }
}

// MARK: - SwiftUI

#if os(iOS)
struct BolsoWebView: UIViewRepresentable {
    func makeCoordinator() -> WebViewFactory { WebViewFactory() }
    func makeUIView(context: Context) -> WKWebView { context.coordinator.webView }
    func updateUIView(_ view: WKWebView, context: Context) {}
}
#else
struct BolsoWebView: NSViewRepresentable {
    func makeCoordinator() -> WebViewFactory { WebViewFactory() }
    func makeNSView(context: Context) -> WKWebView { context.coordinator.webView }
    func updateNSView(_ view: WKWebView, context: Context) {}
}
#endif
