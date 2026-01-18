//
//  EditSkillView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/11/26.
//


import SwiftUI

struct EditSkillView: View {
    @Environment(\.dismiss) private var dismiss

    let skill: Skill
    let onSave: (Skill) -> Void
    let onDelete: () -> Void

    // Edit Skill
    @State private var name: String
    @State private var proficiency: Double
    
    @State private var profileService = ProfileService()
    
    // UI state
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var shakeTrigger: Int = 0

    init(skill: Skill, onSave: @escaping (Skill) -> Void, onDelete: @escaping () -> Void) {
        self.skill = skill
        self.onSave = onSave
        self.onDelete = onDelete

        _name = State(initialValue: skill.name)
        _proficiency = State(initialValue: Double(skill.proficiency))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Skill")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                Text(name)
                    .foregroundStyle(.secondary)
                    .font(.default)

                VStack(alignment: .leading) {
                    HStack {
                        Slider(value: $proficiency, in: 1...10, step: 1)
                        Text("\(Int(proficiency))/10")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if !message.isEmpty {
                HStack {
                    Spacer()
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
                .transition(.opacity)
                .padding(.vertical, 6)
            }
            

            HStack {
                Button(role: .destructive) {
                    Task { await deleteSkill() }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(Color(.systemRed))

                Spacer()

                Button("Cancel") { dismiss() }

                Button(action: {
                    Task{ await updateSkill() }
                }, label: {
                    HStack(spacing: 10) {
                        if isLoading {
                            ProgressView().controlSize(.small)
                        }
                        
                        Text("Save")
                    }
                })
                .keyboardShortcut(.defaultAction)
                .disabled(isLoading)
                .shake(shakeTrigger)
                .animation(.snappy, value: isLoading)
            }
        }
        .padding(20)
        .frame(minWidth: 440, minHeight: 260)
    }
    
    private func updateSkill() async {
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let resp = try await profileService.updateSkill(
                token: token,
                id: skill.id.uuidString,
                proficiency: Int(proficiency)
            )
            
            let trimmed = resp.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                return
            }
            
            let updated = Skill(id: resp.id, name: trimmed, proficiency: resp.proficiency)
            onSave(updated)
            dismiss()
        } catch let error as SkillError {
            switch error {
            case .skillnotfound:
                message = "Skill not found"
                
            case .server:
                message = "Server error. Please try again."
            }
            shakeTrigger += 1
        } catch {
            message = "Something went wrong. Please try again."
            shakeTrigger += 1
        }
    }
    
    private func deleteSkill() async {
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await profileService.deleteSkill(token: token, id: skill.id.uuidString)
            
            onDelete()
            dismiss()
        } catch let error as SkillError {
            switch error {
            case .skillnotfound:
                message = "Skill not found"
            case .server:
                message = "Server error. Please try again."
            }
            shakeTrigger += 1
        } catch {
            message = "Something went wrong. Please try again."
            shakeTrigger += 1
        }
    }

}

#Preview {
    EditSkillView(
        skill: Skill(name: "SwiftUI", proficiency: 7),
        onSave: { _ in },
        onDelete: {}
    )
    .frame(width: 600, height: 200)
}
