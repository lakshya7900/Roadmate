import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let members: [ProjectMember]
    let original: TaskItem
    let onSave: (TaskItem) -> Void

    @State private var title: String
    @State private var details: String
    @State private var status: TaskStatus
    @State private var owner: String
    @State private var difficulty: Double

    init(task: TaskItem, members: [ProjectMember], onSave: @escaping (TaskItem) -> Void) {
        self.original = task
        self.members = members
        self.onSave = onSave

        _title = State(initialValue: task.title)
        _details = State(initialValue: task.details)
        _status = State(initialValue: task.status)
        _owner = State(initialValue: task.ownerUsername ?? "")
        _difficulty = State(initialValue: Double(task.difficulty))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Task")
                .font(.title2).fontWeight(.semibold)

            Form {
                TextField("Title", text: $title)

                TextField("Details", text: $details, axis: .vertical)
                    .lineLimit(3...8)

                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { s in
                        Text(s.title).tag(s)
                    }
                }

                Picker("Owner", selection: $owner) {
                    Text("Unassigned").tag("")
                    ForEach(members) { m in
                        Text(m.username).tag(m.username)
                    }
                }

                VStack(alignment: .leading) {
                    Text("Difficulty: \(Int(difficulty))/5")
                    Slider(value: $difficulty, in: 1...5, step: 1)
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    var updated = original
                    updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    updated.details = details
                    updated.status = status
                    updated.ownerUsername = owner.isEmpty ? nil : owner
                    updated.difficulty = Int(difficulty)
                    onSave(updated)
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 420)
    }
}
