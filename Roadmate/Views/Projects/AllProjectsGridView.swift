import SwiftUI

struct AllProjectsGridView: View {
    let projects: [Project]
    let onSelect: (UUID) -> Void

    private let cols = [
        GridItem(.adaptive(minimum: 180), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("All Projects")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 6)

                LazyVGrid(columns: cols, spacing: 14) {
                    ForEach(projects) { project in
                        ProjectTile(project: project)
                            .onTapGesture { onSelect(project.id) }
                    }
                }

                if projects.isEmpty {
                    Text("No projects yet. Click + to create one.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
