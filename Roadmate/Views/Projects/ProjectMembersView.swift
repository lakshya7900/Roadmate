import SwiftUI

struct ProjectMembersView: View {
    @Binding var project: Project
    @State private var showAdd = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Team")
                    .font(.headline)
                Spacer()
                Button {
                    showAdd = true
                } label: {
                    Label("Add Member", systemImage: "plus")
                }
            }

            List {
                ForEach(project.members) { member in
                    HStack {
                        Text(member.username)
                        Spacer()
                        Text(member.role.label)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    project.members.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.inset)

            Spacer()
        }
        .sheet(isPresented: $showAdd) {
            AddMemberView { member in
                project.members.append(member)
            }
            .frame(minWidth: 420, minHeight: 260)
        }
        .padding(12)
    }
}
