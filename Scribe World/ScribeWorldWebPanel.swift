import SwiftUI
import WebKit

// WKWebView wrapper for fullscreen + Settings privacy panel.
struct ScribeWorldWebPanel: UIViewRepresentable {
    let scribeWorldURLString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.bounces = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = .black
        if let url = URL(string: scribeWorldURLString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // MUST be empty — do NOT reload URL on SwiftUI re-renders.
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
