import UIKit
import WebKit

final class WebViewController: UIViewController {
    private var webView: WKWebView!
    private var downloads: [ObjectIdentifier: URL] = [:]

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(LocalFilesHandler(), forURLScheme: LocalFilesHandler.scheme)

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        // A página já trata as áreas seguras com env(safe-area-inset-*).
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = UIColor(named: "LaunchBackground")
        webView.scrollView.backgroundColor = webView.backgroundColor
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: LocalFilesHandler.startURL))
    }

    /// PDF e Excel vão para a folha de compartilhamento: Salvar em Arquivos, AirDrop, Mail etc.
    private func share(_ file: URL) {
        let sheet = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        // No iPad a folha é um popover e precisa de uma âncora.
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        sheet.popoverPresentationController?.permittedArrowDirections = []
        present(sheet, animated: true)
    }

    private func showDownloadError() {
        let alert = UIAlertController(title: "Não foi possível salvar o arquivo", message: "Tente exportar de novo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor action: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if action.shouldPerformDownload {
            decisionHandler(.download)
            return
        }
        guard let url = action.request.url, let scheme = url.scheme?.lowercased() else {
            decisionHandler(.cancel)
            return
        }
        // Links externos abrem no Safari; o app só navega nos próprios arquivos.
        let isInternal = [LocalFilesHandler.scheme, "about", "blob", "data"].contains(scheme)
        if isInternal || action.targetFrame?.isMainFrame == false {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        #if DEBUG
        runSelfTestIfRequested()
        #endif
    }

    /// O iOS pode encerrar o processo da página em segundo plano; sem isso a tela ficaria em branco.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

extension WebViewController: WKUIDelegate {
    /// Links com target="_blank" não têm janela no WKWebView: abrem no Safari.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for action: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = action.request.url { UIApplication.shared.open(url) }
        return nil
    }
}

extension WebViewController: WKDownloadDelegate {
    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            completionHandler(nil)
            showDownloadError()
            return
        }
        let file = folder.appendingPathComponent((suggestedFilename as NSString).lastPathComponent)
        downloads[ObjectIdentifier(download)] = file
        completionHandler(file)
    }

    func downloadDidFinish(_ download: WKDownload) {
        if let file = downloads.removeValue(forKey: ObjectIdentifier(download)) { share(file) }
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        downloads.removeValue(forKey: ObjectIdentifier(download))
        showDownloadError()
    }
}

#if DEBUG
extension WebViewController {
    /// Só em Debug, com o argumento -BolsoSelfTest: confere na página real, sem login, o que o
    /// app depende e grava o resultado em Documents/selftest.json.
    private func runSelfTestIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-BolsoSelfTest") else { return }
        let script = """
        const before = localStorage.getItem('bolso-selftest');
        localStorage.setItem('bolso-selftest', String(Date.now()));
        const cfg = window.BOLSO_CONFIG;
        let supabaseStatus = 'erro';
        try {
          const r = await fetch(cfg.supabaseUrl + '/auth/v1/settings', {headers: {apikey: cfg.supabaseKey}});
          supabaseStatus = r.status;
        } catch (e) { supabaseStatus = String(e); }
        let loginProbe = 'erro';
        try {
          const r = await fetch(cfg.supabaseUrl + '/auth/v1/token?grant_type=password', {method: 'POST', headers: {apikey: cfg.supabaseKey, 'Content-Type': 'application/json'}, body: '{}'});
          loginProbe = r.status;
        } catch (e) { loginProbe = String(e); }
        let libs = {};
        for (const k of Object.keys(LIBS)) {
          try { await loadLib(k); libs[k] = 'ok ' + LIBS[k]; } catch (e) { libs[k] = String(e); }
        }
        await saveFile('Bolso-teste.pdf', new TextEncoder().encode('%PDF-1.4 teste'));
        return JSON.stringify({origin: location.href, before, supabaseLib: typeof supabase, supabaseStatus, loginProbe, libs, jsPDF: !!window.jspdf, XLSX: !!window.XLSX});
        """
        webView.callAsyncJavaScript(script, arguments: [:], in: nil, in: .page) { result in
            let text: String
            switch result {
            case .success(let value): text = "\(value)"
            case .failure(let error): text = "ERRO: \(error)"
            }
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try? text.write(to: docs.appendingPathComponent("selftest.json"), atomically: true, encoding: .utf8)
        }
    }
}
#endif
