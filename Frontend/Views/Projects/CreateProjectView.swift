//
//  CreateProjectView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/9/26.
//

import SwiftUI

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionState.self) private var session
    
    @State private var projectService = ProjectService()

    let onCreate: (Project) -> Void

    @State private var name = ""
    @State private var description = ""
    
    // UI state
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var shakeTrigger: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(alignment: .top) {
                Text("New Project")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            VStack(spacing: 12) {
                TextField("Project name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLoading)

                TextField("Description (optional)", text: $description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .disabled(isLoading)
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )

            // Complaint row aligned with the buttons
            HStack {
                Spacer()
                if !message.isEmpty {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.callout)
                        .transition(.opacity)
                }
            }
            .animation(.snappy, value: message)

            HStack(spacing: 10) {
                Spacer()

                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .disabled(isLoading)

                Button {
                    Task { await createProject() }
                } label: {
                    HStack(spacing: 10) {
                        if isLoading {
                            ProgressView().controlSize(.small)
                        }
                        Text(isLoading ? "Creating…" : "Create")
                    }
                    .frame(minWidth: 120)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isLoading)
                .shake(shakeTrigger)
                .animation(.snappy, value: isLoading)
            }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 320)
    }
    
    private func createProject() async {
        guard let token = KeychainService.loadToken() else {
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                message = "Project name cannot be empty."
                shakeTrigger += 1
                return
            }
            
            
            let resp = try await projectService.createProject(
                token: token,
                name: trimmedName,
                description: description
            )
            
            onCreate(resp)
            dismiss()
        } catch {
            message = "Failed to create project."
            shakeTrigger += 1
            print("CreateProject error:", error)
        }
    }
}

#Preview {
    CreateProjectView(onCreate: { _ in })
        .environment(SessionState())
}
