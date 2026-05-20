import SwiftUI
import WebKit

// WKWebView wrapper for fullscreen + Settings privacy panel.
struct CrosswordQuillWebPanel: UIViewRepresentable {
    let crosswordQuillURLString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.bounces = true
        webView.backgroundColor = .white
        webView.isOpaque = true
        if let url = URL(string: crosswordQuillURLString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // MUST be empty — do NOT reload URL on SwiftUI re-renders.
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
