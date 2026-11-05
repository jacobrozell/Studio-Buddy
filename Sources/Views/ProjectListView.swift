import SwiftUI
import SwiftData

/// Lists all of the user's release projects (albums, EPs, etc.).
/// One split view collapses on phones and when an iPad window is narrow.
struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.marketingScene) private var marketingScene
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Query(sort: \Project.dateCreated, order: .reverse) private var projects: [Project]

    @State private var showingNewProject = false
    @State private var showingSettings = false
    @State private var projectPendingDelete: Project?
    @State private var selectedProjectID: UUID?
    @State private var containerWidth: CGFloat = 0

    var body: some View {
        projectSplitView
            .onContainerWidthChange($containerWidth)
        .sheet(isPresented: $showingSettings) { SettingsView() }
        .sheet(isPresented: $showingNewProject) { ProjectEditorView(project: nil) }
        .confirmationDialog(
            deleteDialogTitle,
            isPresented: deleteDialogPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let project = projectPendingDelete { deleteProject(project) }
            }
            Button("Cancel", role: .cancel) { projectPendingDelete = nil }
        } message: {
            if let project = projectPendingDelete {
                Text("Songs stay in your library; only \"\(project.title)\" and its running order are removed.")
            }
        }
        .onChange(of: projectIDs) { _, ids in
            guard let selectedProjectID, !ids.contains(selectedProjectID) else { return }
            self.selectedProjectID = nil
        }
        .onAppear {
            if marketingScene == .project, selectedProjectID == nil {
                selectedProjectID = projects.first?.id
            }
        }
        .verticalTabBarClearance()
    }

    private var usesSplitLayout: Bool {
        AdaptiveLayout.usesSplitNavigation(horizontal: horizontalSizeClass, vertical: verticalSizeClass)
    }

    private var sidebarWidth: SplitColumnWidth {
        AdaptiveLayout.splitColumnWidth(containerWidth: containerWidth, dynamicType: dynamicTypeSize)
    }

    private var selectedProject: Project? {
        guard let selectedProjectID else { return nil }
        return projects.first { $0.id == selectedProjectID }
    }

    private var projectIDs: Set<UUID> {
        Set(projects.map(\.id))
    }

    private var projectSplitView: some View {
        NavigationSplitView {
            projectListContent
                .navigationTitle("Projects")
                .studioNavigationBarBackground()
                .toolbar { projectToolbarContent }
                .navigationSplitViewColumnWidth(
                    min: sidebarWidth.min,
                    ideal: sidebarWidth.ideal,
                    max: sidebarWidth.max
                )
        } detail: {
            if let selectedProject {
                ProjectDetailView(project: selectedProject)
            } else {
                ContentUnavailableView {
                    Label("Select a Project", systemImage: "square.stack.3d.up")
                } description: {
                    Text("Choose a release project to edit its running order and energy flow.")
                }
                .adaptiveEmptyStateLayout()
                .studioNavigationBarBackground()
                .accessibilityIdentifier(A11yID.Split.selectProject)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environment(\.horizontalSizeClass, usesSplitLayout ? horizontalSizeClass : .compact)
    }

    @ViewBuilder
    private var projectListContent: some View {
        if projects.isEmpty {
            emptyState
        } else {
            List(selection: $selectedProjectID) {
                ForEach(projects) { project in
                    projectRow(project)
                }
            }
            .listStyle(.plain)
        }
    }

    private func projectRow(_ project: Project) -> some View {
        ProjectRow(project: project)
            .tag(project.id)
            .listSidebarSelection(isSelected: selectedProjectID == project.id, enabled: usesSplitLayout)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) { projectPendingDelete = project } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    @ToolbarContentBuilder
    private var projectToolbarContent: some ToolbarContent {
        if ReleaseSurface.settings {
            ToolbarItem(placement: .topBarLeading) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
                .accessibilityIdentifier(A11yID.Settings.button)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button { showingNewProject = true } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("New project")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Projects", systemImage: "square.stack.3d.up")
        } description: {
            Text("Create an album or EP and start sequencing your tracks.")
        } actions: {
            Button("New Project") { showingNewProject = true }
                .buttonStyle(.borderedProminent)
        }
        .adaptiveEmptyStateLayout()
    }

    private func deleteProject(_ project: Project) {
        if selectedProjectID == project.id { selectedProjectID = nil }
        modelContext.delete(project)
        projectPendingDelete = nil
        Haptics.tap()
    }

    private var deleteDialogTitle: String {
        guard let project = projectPendingDelete else { return "Delete Project?" }
        return "Delete \"\(project.title)\"?"
    }

    private var deleteDialogPresented: Binding<Bool> {
        Binding(
            get: { projectPendingDelete != nil },
            set: { if !$0 { projectPendingDelete = nil } }
        )
    }
}

/// One row in the project list, summarising track count and runtime.
private struct ProjectRow: View {
    let project: Project

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor.gradient)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "opticaldisc")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(project.title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var subtitle: String {
        var parts = ["\(project.kind.displayName)", "\(project.tracks.count) tracks", runtime]
        if project.totalTrackCount > 0 {
            parts.append("\(project.releasedTrackCount)/\(project.totalTrackCount) released")
        }
        return parts.joined(separator: " · ")
    }

    private var accessibilitySummary: String {
        "\(project.title), \(subtitle)"
    }

    private var runtime: String {
        let total = Int(project.totalDuration.rounded())
        guard total > 0 else { return "0:00" }
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
