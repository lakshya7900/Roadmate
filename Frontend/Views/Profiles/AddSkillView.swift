//
//  AddSkillView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/8/26.
//

import SwiftUI

struct AddSkillView: View {
    @Environment(\.dismiss) private var dismiss

    // change: async/throws handler
    let onAdd: (Skill) -> Void

    @State private var name: String = ""
    @State private var proficiency: Double = 5
    
    @State private var profileService = ProfileService()
    
    // UI state
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var shakeTrigger: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Skill")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                TextField("Name (e.g., Swift, React, Postgres)", text: $name)
                    .disabled(isLoading)

                HStack {
                    Text("Proficiency")
                    Spacer()
                    Slider(value: $proficiency, in: 1...10, step: 1)
                        .disabled(isLoading)
                    Text("\(Int(proficiency))/10")
                        .foregroundStyle(.secondary)
                }
            }

//            if !complaint.isEmpty {
//                HStack {
//                    Spacer()
//                    Label(complaint, systemImage: "exclamationmark.triangle.fill")
//                        .foregroundStyle(.red)
//                }
//                .transition(.opacity)
//            }

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
                        Task { await addSkill() }
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
        }
        .padding(20)
        .animation(.snappy, value: message)
    }

    private func addSkill() async {
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }
        
        isLoading = true
        defer { isLoading = false }

        do {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                shakeTrigger += 1
                message = "Skill name is empty"
                return
            }
            
            let resp = try await profileService.addSkill(
                token: token,
                name: trimmed,
                proficiency: Int(proficiency)
            )
            
            let added = Skill(id: resp.id, name: trimmed, proficiency: resp.proficiency)
            
            onAdd(added)
            dismiss()
        } catch let APIError.badStatus(code, body) {
            if code == 409 {
                shakeTrigger += 1
                message = "Skill already exists."
            } else {
                shakeTrigger += 1
                message = "Failed to add skill (\(code))."
                print("AddSkill error body:", body)
            }
        } catch {
            shakeTrigger += 1
            message = "Failed to add skill."
            print("AddSkill error:", error)
        }
    }
}

#Preview {
    AddSkillView { _ in
        // pretend it succeeds
    }
    .frame(width: 600, height: 200)
}
