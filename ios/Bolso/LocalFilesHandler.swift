import UniformTypeIdentifiers
import WebKit

/// Serve os arquivos do site (pasta www do app) pelo endereço bolso://app/.
/// Uma origem própria mantém o localStorage, e com ele o login, entre as aberturas do app.
final class LocalFilesHandler: NSObject, WKURLSchemeHandler {
    static let scheme = "bolso"
    static let startURL = URL(string: "\(scheme)://app/index.html")!

    private let root = Bundle.main.bundleURL.appendingPathComponent("www", isDirectory: true).standardizedFileURL

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else {
            task.didFailWithError(URLError(.badURL))
            return
        }
        let file = root.appendingPathComponent(url.path).standardizedFileURL
        guard file.path.hasPrefix(root.path + "/"), let data = try? Data(contentsOf: file) else {
            respond(to: task, url: url, status: 404, type: "text/plain", data: Data())
            return
        }
        let type = UTType(filenameExtension: file.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        respond(to: task, url: url, status: 200, type: type, data: data)
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}

    private func respond(to task: WKURLSchemeTask, url: URL, status: Int, type: String, data: Data) {
        let headers = ["Content-Type": type, "Content-Length": String(data.count), "Cache-Control": "no-store"]
        task.didReceive(HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!)
        task.didReceive(data)
        task.didFinish()
    }
}
