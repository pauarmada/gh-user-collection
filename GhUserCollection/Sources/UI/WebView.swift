//
//  WebView.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Combine
import SwiftUI
import WebKit

// Rudimentary SwiftUI WebView implementation with basic controls
struct WebView: View {
    let url: URL
    let navigationTitle: String
    
    @State var canGoBack = false
    @State var canGoForward = false
    @State var action: WebViewRepresentable.Action?
    
    var body: some View {
        VStack {
            WebViewRepresentable(
                urlRequest: URLRequest(url: url),
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                action: $action
            )
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                imageButton(action: .back)
                    .disabled(!canGoBack)
                imageButton(action: .forward)
                    .disabled(!canGoForward)
                Spacer()
                imageButton(action: .refresh)
            }
        }
    }
    
    @ViewBuilder
    func imageButton(action: WebViewRepresentable.Action) -> some View {
        // Map the action with an icon and a pleasing size
        let (systemName, size) = switch action {
        case .back:
            ("arrowtriangle.backward.fill", 20.0)
        case .forward:
            ("arrowtriangle.forward.fill", 20.0)
        case .refresh:
            ("arrow.clockwise.circle.fill", 32.0)
        }
        
        Button(action: {
            self.action = action
        }) {
            // To increase the tappable area and keep all sizes the same, wrap in zstack
            ZStack(alignment: .center) {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: size, height: size)
            }.frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    enum Action {
        case back
        case forward
        case refresh
    }
    
    let urlRequest: URLRequest
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var action: Action?
    
    func makeUIView(context: Context) -> WKWebView {
        context.coordinator.makeWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        switch action {
        case .back:
            uiView.goBack()
        case .forward:
            uiView.goForward()
        case .refresh:
            uiView.reload()
        case .none:
            break
        }
        
        // After performing action, reset the action back to nil
        DispatchQueue.main.async {
            action = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        // We create a coordinator in order to listen to the
        // canGoBack and canGoForward events of the webview
        Coordinator(self)
    }
    
    class Coordinator {
        var parent: WebViewRepresentable
        private var cancellables: [AnyCancellable] = []
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func makeWebView() -> WKWebView {
            cancellables.removeAll()
            
            let webView = WKWebView(frame: .zero)
            webView.load(parent.urlRequest)
            
            webView.publisher(for: \.canGoBack)
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.parent.canGoBack = $0
                }
                .store(in: &cancellables)
            
            webView.publisher(for: \.canGoForward)
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.parent.canGoForward = $0
                }
                .store(in: &cancellables)
            
            return webView
        }
    }
}

#Preview {
    NavigationStack {
        WebView(
            url: URL(string: "https://github.com/pauarmada/gh-user-collection")!,
            navigationTitle: "Title"
        )
    }
}
