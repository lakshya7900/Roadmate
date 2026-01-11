import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    @State private var project: Project

    init(project: Project) {
        _project = State(initialValue: project)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            TabView {
                ProjectOverviewView(project: $project)
                    .tabItem { Label("Overview", systemImage: "doc.text") }

                ProjectBoardView(project: $project)
                    .tabItem { Label("Board", systemImage: "square.grid.3x1.folder.badge.plus") }

                ProjectMembersView(project: $project)
                    .tabItem { Label("Team", systemImage: "person.2") }
            }
            .padding(12)
        }
        .onChange(of: project) { _, newValue in
            projectStore.upsert(newValue)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.name)
                .font(.title2)
                .fontWeight(.semibold)

            if !project.description.isEmpty {
                Text(project.description)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}
