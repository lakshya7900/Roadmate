import SwiftUI

struct ProjectTile: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(project.name)
                .font(.headline)
                .lineLimit(2)

            Text("\(project.tasks.count) tasks • \(project.members.count) members")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(height: 120)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ProjectTile(project: Project(
        name: "Demo: Roadmate Planner",
        description: "Seed",
        members: [ProjectMember(username: "me", role: .owner)],
        tasks: [TaskItem(title: "Task", status: .backlog)]
    ))
    .padding()
    .frame(width: 260)
}
