import SwiftUI

@main
struct CrosswordQuillDailyApp: App {
    @State private var crosswordQuillLinkReady: Bool? = nil
    private let crosswordQuillSourceLink = "https://example.com"
    private let crosswordQuillCheckDomain = "example"

    @StateObject private var store = QuillStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = crosswordQuillLinkReady {
                    if ready {
                        CrosswordQuillWebPanel(crosswordQuillURLString: crosswordQuillSourceLink)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        ContentView()
                            .environmentObject(store)
                    }
                } else {
                    CrosswordQuillLoadingScreen()
                        .onAppear { crosswordQuillCheckLink() }
                }
            }
            .preferredColorScheme(.light)
        }
    }

    private func crosswordQuillCheckLink() {
        guard let url = URL(string: crosswordQuillSourceLink) else {
            crosswordQuillLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = CrosswordQuillRedirectTracker(checkDomain: crosswordQuillCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    crosswordQuillLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(crosswordQuillCheckDomain) {
                    crosswordQuillLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(crosswordQuillCheckDomain) {
                    crosswordQuillLinkReady = false; return
                }
                if error != nil {
                    crosswordQuillLinkReady = false; return
                }
                crosswordQuillLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if crosswordQuillLinkReady == nil { crosswordQuillLinkReady = false }
        }
    }
}

final class CrosswordQuillRedirectTracker: NSObject, URLSessionTaskDelegate {
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
