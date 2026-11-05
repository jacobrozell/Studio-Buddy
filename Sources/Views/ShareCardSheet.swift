import SwiftUI

/// Presents a live preview of a shareable release card, lets the user pick a
/// format, and shares the rendered PNG via the system share sheet.
struct ShareCardSheet: View {
    let content: CardContent
    @Environment(\.dismiss) private var dismiss

    @State private var format: CardFormat = .square
    @State private var renderedURL: URL?
    @State private var isRendering = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Format", selection: $format) {
                    ForEach(CardFormat.allCases) { format in
                        Text(format.localizedName).tag(format)
                    }
                }
                .pickerStyle(.segmented)

                // Preview is the same view that gets rendered to the PNG.
                ScrollView {
                    ShareCardView(content: content, format: format)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8, y: 4)
                        .padding(.vertical, 8)
                }

                if let url = renderedURL {
                    ShareLink(item: url, preview: SharePreview("Release Card", image: Image(systemName: "photo"))) {
                        Label("Share Image", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .simultaneousGesture(TapGesture().onEnded { logShare() })
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .padding()
            .navigationTitle("Share Card")
            .studioNavigationBarBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.done) { dismiss() }
                }
            }
            // Re-render whenever the chosen format changes.
            .task(id: format) { render() }
        }
    }

    private func render() {
        isRendering = true
        let url = ReleaseCardRenderer.renderPNG(content: content, format: format)
        renderedURL = url
        isRendering = false
        if url == nil {
            AppLog.shared.error(
                .ui,
                eventName: "share_card_render_failed",
                message: "Share card render failed.",
                metadata: ["format": format.rawValue.lowercased()]
            )
        }
    }

    private func logShare() {
        AppLog.shared.info(
            .ui,
            eventName: "share_card_exported",
            message: "Share card shared.",
            metadata: ["format": format.rawValue.lowercased()]
        )
    }
}
