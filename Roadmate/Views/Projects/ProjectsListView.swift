import SwiftUI

struct ProjectsListView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    @State private var selectedProjectId: UUID?
    @State private var showCreate = false

    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Text("Projects")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Button {
                        showCreate = true
                    } label: {
                        Label("New Project", systemImage: "plus")
                    }
                }
                .padding([.top, .horizontal], 16)

                List(selection: $selectedProjectId) {
                    ForEach(projectStore.projects) { project in
                        Text(project.name)
                            .tag(project.id as UUID?)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    projectStore.delete(project.id)
                                    if selectedProjectId == project.id { selectedProjectId = nil }
                                }
                            }
                    }
                }
                .listStyle(.inset)
            }
        } detail: {
            if let id = selectedProjectId,
               let project = projectStore.projects.first(where: { $0.id == id }) {
                ProjectDetailView(project: project)
            } else {
                EmptyStateView()
                    .overlay(alignment: .topLeading) {
                        Text("Select a project")
                            .padding(20)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateProjectView { newProject in
                projectStore.upsert(newProject)
                selectedProjectId = newProject.id
            }
            .frame(minWidth: 520, minHeight: 420)
        }
    }
}
