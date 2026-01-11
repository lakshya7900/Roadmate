import SwiftUI

struct ProjectOverviewView: View {
    @Binding var project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Description")
                .font(.headline)

            TextField("Description", text: $project.description, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...10)

            Divider().padding(.vertical, 8)

            Text("Quick Stats")
                .font(.headline)

            HStack(spacing: 16) {
                stat("Members", "\(project.members.count)")
                stat("Tasks", "\(project.tasks.count)")
                stat("Done", "\(project.tasks.filter { $0.status == .done }.count)")
            }

            Spacer()
        }
        .padding(12)
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).foregroundStyle(.secondary)
            Text(value).font(.title3).fontWeight(.semibold)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
