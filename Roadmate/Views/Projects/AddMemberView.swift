import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (ProjectMember) -> Void

    @State private var username = ""
    @State private var role: ProjectRole = .fullstack

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Team Member")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                TextField("Username", text: $username)
                Picker("Role", selection: $role) {
                    ForEach(ProjectRole.allCases) { r in
                        Text(r.label).tag(r)
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Add") {
                    onAdd(ProjectMember(username: username.trimmingCharacters(in: .whitespacesAndNewlines), role: role))
                    dismiss()
                }
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
    }
}
