//
//  AddTaskView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/9/26.
//


import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    let members: [ProjectMember]
    let onAdd: (TaskItem) -> Void
    
    @State private var taskSerive = TaskService()

    @State private var title = ""
    @State private var details = ""
    @State private var status: TaskStatus = .backlog
    @State private var assigneeId: UUID? = nil
    @State private var difficulty: Double = 2
    
    // UI state
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var shakeTrigger: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Task")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                TextField("Title", text: $title)
                TextField("Details", text: $details, axis: .vertical)
                    .lineLimit(3...6)

                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { s in
                        Text(s.title).tag(s)
                    }
                }

                Picker("Assignee", selection: $assigneeId) {
                    Text("Unassigned").tag(UUID?.none)
                    ForEach(members) { m in
                        Text(m.username).tag(UUID?.some(m.id))
                    }
                }

                VStack(alignment: .leading) {
                    Text("Difficulty: \(Int(difficulty))/5")
                    Slider(value: $difficulty, in: 1...5, step: 1)
                }
            }
            
            VStack(alignment: .trailing) {
                if !message.isEmpty {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.default)
                }

                HStack {
                    Spacer()
                    Button("Cancel") { dismiss() }
                        .disabled(isLoading)
                    Button(action: {
                        Task { await addTask() }
                    }, label: {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView().controlSize(.small)
                            }
                            Text("Add")
                        }
                    })
                    .disabled(isLoading)
                    .shake(shakeTrigger)
                    .animation(.snappy, value: isLoading)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .animation(.snappy, value: message)
        }
        .padding(20)
    }
    
    private func addTask() async {
        message = ""
        
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty else {
                message = "Task title is empty"
                shakeTrigger += 1
                return
            }
            
            if details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                details = ""
            }
            
            let created = try await taskSerive.addTask(
                token: token,
                projectId: projectId,
                title: trimmedTitle,
                details: details,
                status: status,
                assigneeID: assigneeId,
                difficulty: Int(difficulty)
            )
            
            onAdd(created)
            dismiss()
        } catch {
            message = "Failed to add task"
            shakeTrigger += 1
        }
    }
}


#Preview {
    let sampleMembers: [ProjectMember] = [
        ProjectMember(id: UUID(), username: "alice", roleKey: "frontend"),
        ProjectMember(id: UUID(), username: "bob", roleKey: "backend")
    ]
    AddTaskView(projectId: UUID(), members: sampleMembers) { _ in
        // pretend it succeeds
    }
}
