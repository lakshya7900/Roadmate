import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let members: [ProjectMember]
    let onUpdate: (TaskItem) -> Void
    let onDelete: () -> Void

    @State private var local: TaskItem

    init(task: TaskItem, members: [ProjectMember], onUpdate: @escaping (TaskItem) -> Void, onDelete: @escaping () -> Void) {
        self.task = task
        self.members = members
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _local = State(initialValue: task)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(local.title)
                .font(.headline)

            if !local.details.isEmpty {
                Text(local.details)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack {
                Text("D\(local.difficulty)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let owner = local.ownerUsername, !owner.isEmpty {
                    Text(owner)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Unassigned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Picker("Move to", selection: Binding(
                get: { local.status },
                set: { newValue in local.status = newValue; commit() }
            )) {
                ForEach(TaskStatus.allCases) { s in
                    Text(s.title).tag(s)
                }
            }

            Divider()

            Picker("Owner", selection: Binding(
                get: { local.ownerUsername ?? "" },
                set: { v in local.ownerUsername = v.isEmpty ? nil : v; commit() }
            )) {
                Text("Unassigned").tag("")
                ForEach(members, id: \.id) { m in
                    Text(m.username).tag(m.username)
                }
            }

            Divider()

            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
        .onChange(of: task) { _, newTask in
            local = newTask
        }
    }

    private func commit() {
        onUpdate(local)
    }
}
