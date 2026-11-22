import SwiftUI
import WebKit

@main
struct TrailerParkProductionsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            WebView(url: URL(string: "https://trailerparkproductions.net")!)
                .tabItem { Label("Home", systemImage: "house.fill") }
            WebView(url: URL(string: "https://trailerparkproductions.net/#stories")!)
                .tabItem { Label("Stories", systemImage: "newspaper.fill") }
            WebView(url: URL(string: "https://trailerparkproductions.net/#media")!)
                .tabItem { Label("Media", systemImage: "photo.on.rectangle.angled") }
            WebView(url: URL(string: "https://trailerparkproductions.net/#podcast")!)
                .tabItem { Label("Podcast", systemImage: "mic.fill") }
            WebView(url: URL(string: "https://trailerparkproductions.net/#store")!)
                .tabItem { Label("Store", systemImage: "cart.fill") }
        }
        .accentColor(.red)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.refresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh
        context.coordinator.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?

        @objc func refresh(_ sender: UIRefreshControl) {
            webView?.reload()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }
    }
}
