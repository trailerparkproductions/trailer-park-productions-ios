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
            PageView(url: URL(string: "https://trailerparkproductions.net")!)
                .tabItem { Label("Home", systemImage: "house.fill") }
            PageView(url: URL(string: "https://trailerparkproductions.net/#stories")!)
                .tabItem { Label("Stories", systemImage: "newspaper.fill") }
            PageView(url: URL(string: "https://trailerparkproductions.net/#media")!)
                .tabItem { Label("Media", systemImage: "photo.on.rectangle.angled") }
            PageView(url: URL(string: "https://trailerparkproductions.net/#podcast")!)
                .tabItem { Label("Podcast", systemImage: "mic.fill") }
            PageView(url: URL(string: "https://trailerparkproductions.net/#store")!)
                .tabItem { Label("Store", systemImage: "cart.fill") }
        }
        .accentColor(.red)
    }
}

struct PageView: View {
    let url: URL
    @State private var progress: Double = 0
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var reloadToken = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 34)
                    .padding(3)
                    .background(Color.white)
                    .cornerRadius(7)
                Text("Trailer Park Productions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button(action: shareSite) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black)

            if isLoading && !loadFailed {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                    .frame(height: 2)
            }

            if loadFailed {
                VStack(spacing: 14) {
                    Image(systemName: "wifi.slash")
                        .font(.largeTitle)
                    Text("No connection")
                        .font(.headline)
                    Text("Check your signal and try again.")
                        .foregroundColor(.secondary)
                    Button("Try again") {
                        loadFailed = false
                        isLoading = true
                        reloadToken += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                WebView(url: url, reloadToken: reloadToken, progress: $progress, isLoading: $isLoading, loadFailed: $loadFailed)
            }
        }
    }

    private func shareSite() {
        let items: [Any] = [URL(string: "https://trailerparkproductions.net")!]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(controller, animated: true)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let reloadToken: Int
    @Binding var progress: Double
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Hide the website's own header/nav inside the app — the native tab bar is the only navigation.
        let css = "header.topbar{display:none!important}"
        let script = WKUserScript(
            source: "var style=document.createElement('style');style.innerHTML='\(css)';(document.head||document.documentElement).appendChild(style);",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.refresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh
        context.coordinator.webView = webView
        context.coordinator.observeProgress(of: webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            uiView.load(URLRequest(url: url))
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        weak var webView: WKWebView?
        var lastReloadToken = 0
        private var progressObservation: NSKeyValueObservation?

        init(_ parent: WebView) { self.parent = parent }

        func observeProgress(of webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.progress = webView.estimatedProgress
                }
            }
        }

        @objc func refresh(_ sender: UIRefreshControl) {
            webView?.reload()
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let target = navigationAction.request.url {
                let host = target.host ?? ""
                if target.scheme == "mailto" || target.scheme == "tel" || (!host.isEmpty && !host.hasSuffix("trailerparkproductions.net")) {
                    UIApplication.shared.open(target)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isLoading = true }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.progress = 1
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = true
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
            DispatchQueue.main.async { self.parent.isLoading = false }
        }
    }
}
