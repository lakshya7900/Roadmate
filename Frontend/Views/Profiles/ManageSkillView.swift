//
//  ManageSkillView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/11/26.
//

import SwiftUI

struct ManageSkillsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var skills: [Skill]
    let onSave: () -> Void

    @State private var editing: Skill? = nil
    @State private var hoveredID: UUID?
    
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var profileService = ProfileService()
    @State private var shakeTrigger: Int = 0


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Manage Skills")
                        .font(.title2.weight(.semibold))

                    Text("Edit/Delete skills")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, -2)
                    
                    if !message.isEmpty {
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .font(.callout)
                            .foregroundStyle(Color(.systemRed))
                    }
                }

                Spacer()

                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.separator.opacity(0.6))
            )


            List {
                ForEach(skills) { s in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(s.name)
                                .font(.body.weight(.medium))
                            
                            Text("\(s.proficiency)/10")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Button { editing = s } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)

                            Button(role: .destructive) {
                                Task { await remove(s.id) }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(Color(.systemRed))
                            .disabled(isLoading)

                        }
                        .foregroundStyle(.secondary)
                        .opacity(hoveredID == s.id ? 1 : 0)
                    }
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .onHover { isHovering in
                        hoveredID = isHovering ? s.id : nil
                    }
                    .contextMenu {
                        Button("Edit") { editing = s }
                        Divider()
                        Button("Delete", role: .destructive) { Task{ await remove(s.id) } }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .padding(.vertical, 4)
                    )
                }
                .onDelete { indexSet in
                    skills.remove(atOffsets: indexSet)
                    onSave()
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
        .padding(16)
        .sheet(item: $editing) { s in
            EditSkillView(
                skill: s,
                onSave: { updated in
                    if let idx = skills.firstIndex(where: { $0.id == s.id }) {
                        skills[idx].name = updated.name
                        skills[idx].proficiency = updated.proficiency
                        skills.sort { $0.proficiency > $1.proficiency }
                        onSave()
                    }
                },
                onDelete: {
                    skills.removeAll { $0.id == s.id }
                    onSave()
                }
            )
        }
        .frame(minWidth: 600, minHeight: 200)
    }
    
    private func remove(_ id: UUID) async {
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await profileService.deleteSkill(token: token, id: id.uuidString)

            skills.removeAll { $0.id == id }
            onSave()

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

#Preview("Profile – Demo") {
    struct PreviewContainer: View {
        @State var skills: [Skill] = [
            Skill(name: "Swift", proficiency: 2),
            Skill(name: "SwiftUI", proficiency: 5),
            Skill(name: "Go", proficiency: 7),
            Skill(name: "React", proficiency: 10),
            Skill(name: "PostgreSQL", proficiency: 1),
        ]

        var body: some View {
            ManageSkillsView(
                skills: $skills,
                onSave: {}
            )
        }
    }

    return PreviewContainer()
        .frame(width: 600, height: 400)
}

