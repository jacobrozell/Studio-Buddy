import SwiftUI
import SwiftData

@main
struct StudioBuddyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    /// Shared SwiftData container for the whole app.
    let modelContainer: ModelContainer

    @State private var audioPlayer = AudioPlayer()

    init() {
        UITestLaunch.prepareAppDefaultsIfNeeded()
        do {
            modelContainer = try ModelContainerFactory.makeContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        AppLog.shared.info(.app, eventName: "app_launched", message: "Studio Buddy started")
    }

    var body: some Scene {
        WindowGroup {
            DependencyRoot()
                .environment(audioPlayer)
        }
        .modelContainer(modelContainer)
    }
}

/// Injects repositories once `modelContext` is available from the container.
private struct DependencyRoot: View {
    @Environment(\.modelContext) private var modelContext
    @State private var openInImportMessage: String?

    var body: some View {
        RootView()
            .environment(\.appDependencies, .live(context: modelContext))
            .onOpenURL { url in
                Task { @MainActor in
                    openInImportMessage = await OpenInAudioImport.importURL(url, context: modelContext)
                }
            }
            .alert(
                "Import",
                isPresented: Binding(
                    get: { openInImportMessage != nil },
                    set: { if !$0 { openInImportMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { openInImportMessage = nil }
            } message: {
                Text(openInImportMessage ?? "")
            }
    }
}
