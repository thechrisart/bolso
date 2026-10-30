import Foundation
import WebKit

/// Serve os arquivos da pasta Web do pacote do app em bolso://localhost/…
/// Assim a página tem uma origem estável (o login fica salvo) e funciona
/// mesmo que o GitHub Pages esteja fora do ar.
final class LocalFileSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url, let file = Self.file(for: url),
              let data = try? Data(contentsOf: file) else {
            task.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        let headers = [
            "Content-Type": Self.mimeType(for: file.pathExtension),
            "Content-Length": String(data.count),
            "Cache-Control": "no-cache",
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}

    /// Procura em Web/<caminho> e, se o Xcode tiver copiado os arquivos
    /// direto para a raiz do pacote, pelo nome do arquivo.
    private static func file(for url: URL) -> URL? {
        guard let base = Bundle.main.resourceURL else { return nil }
        var path = url.path
        if path.isEmpty || path == "/" { path = "/index.html" }
        guard !path.contains("..") else { return nil }
        let candidates = [
            base.appendingPathComponent("Web").appendingPathComponent(path),
            base.appendingPathComponent((path as NSString).lastPathComponent),
        ]
        return candidates.first { FileManager.default.fileExists(atPath: $0.path) }
    }

    private static func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html": return "text/html; charset=utf-8"
        case "js": return "text/javascript; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "json": return "application/json"
        case "svg": return "image/svg+xml"
        case "png": return "image/png"
        default: return "application/octet-stream"
        }
    }
}
