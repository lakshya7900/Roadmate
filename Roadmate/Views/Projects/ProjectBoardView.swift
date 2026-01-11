import SwiftUI

struct ProjectBoardView: View {
    @Binding var project: Project
    @State private var showAddTask = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Board")
                    .font(.headline)
                Spacer()
                Button {
                    showAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(TaskStatus.allCases) { status in
                        boardColumn(status)
                    }
                }
                .padding(.vertical, 8)
            }

            Spacer()
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView(members: project.members) { task in
                project.tasks.append(task)
            }
            .frame(minWidth: 520, minHeight: 360)
        }
        .padding(12)
    }

    private func boardColumn(_ status: TaskStatus) -> some View {
        let tasks = project.tasks.filter { $0.status == status }

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: status.systemImage)
                Text(status.title)
                    .font(.headline)
                Spacer()
                Text("\(tasks.count)")
                    .foregroundStyle(.secondary)
            }

            ForEach(tasks) { task in
                TaskCardView(
                    task: task,
                    members: project.members,
                    onUpdate: { updated in
                        if let idx = project.tasks.firstIndex(where: { $0.id == updated.id }) {
                            project.tasks[idx] = updated
                        }
                    },
                    onDelete: {
                        project.tasks.removeAll { $0.id == task.id }
                    }
                )
            }

            Spacer(minLength: 8)
        }
        .padding(12)
        .frame(width: 260)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
