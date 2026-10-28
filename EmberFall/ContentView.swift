import SwiftUI
import WebKit
import Photos

final class SceneModel: ObservableObject {
    weak var web: WKWebView?
    @Published var message: String? = nil
    @Published var busy = false

    func save() {
        guard let web = web else { return }
        busy = true
        web.evaluateJavaScript("document.getElementById('hint').classList.add('off')") { _, _ in
            let cfg = WKSnapshotConfiguration()
            cfg.afterScreenUpdates = true
            web.takeSnapshot(with: cfg) { image, _ in
                guard let image = image else {
                    self.finish("Could not capture the wallpaper.")
                    return
                }
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    guard status == .authorized || status == .limited else {
                        self.finish("Allow Photos access in Settings to save the wallpaper.")
                        return
                    }
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { ok, _ in
                        self.finish(ok ? "Saved to Photos. Open it, tap Share, then Use as Wallpaper." : "Could not save the wallpaper.")
                    }
                }
            }
        }
    }

    func finish(_ text: String) {
        DispatchQueue.main.async {
            self.busy = false
            self.message = text
        }
    }
}

struct ContentView: View {
    @StateObject private var model = SceneModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            SceneWebView(model: model)
            Button(action: { model.save() }) {
                Text(model.busy ? "Saving" : "Save as wallpaper")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 13)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .disabled(model.busy)
            .padding(.bottom, 36)
        }
        .alert("Wallpaper", isPresented: Binding(
            get: { model.message != nil },
            set: { if !$0 { model.message = nil } }
        )) {
            Button("Open Photos") {
                if let url = URL(string: "photos-redirect://") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Done", role: .cancel) {}
        } message: {
            Text(model.message ?? "")
        }
    }
}

struct SceneWebView: UIViewRepresentable {
    let model: SceneModel

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = true
        web.backgroundColor = .black
        web.scrollView.backgroundColor = .black
        web.scrollView.isScrollEnabled = false
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsLinkPreview = false
        model.web = web
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
