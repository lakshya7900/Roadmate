//
//  EditEducationView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/11/26.
//


import SwiftUI

struct EditEducationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var profileService = ProfileService()

    @State private var school : String
    @State private var degree : String
    @State private var major : String
    
    @State private var startYear: String
    @State private var endYear: String
    
    // UI state
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var shakeTrigger: Int = 0
    @State private var showAlert = false
    
    let education: Education
    let onSave: (Education) -> Void
    let onDelete: () -> Void

    init(education: Education, onSave: @escaping (Education) -> Void, onDelete: @escaping () -> Void) {
        self.education = education
        self.onSave = onSave
        self.onDelete = onDelete

        _school = State(initialValue: education.school)
        _degree = State(initialValue: education.degree)
        _major = State(initialValue: education.major)
        _startYear = State(initialValue: String(education.startyear))
        _endYear = State(initialValue: String(education.endyear))
    }
    
    private var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 40)...(current + 15))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Education")
                .font(.title2)
                .fontWeight(.semibold)
            
            Form {
                VStack(spacing: 20) {
                    TextField("School Name", text: $school)
                    TextField("Degree", text: $degree)
                    TextField("Major", text: $major)
                    
                    HStack(spacing: 80) {
                        TextField("Start Year", text: $startYear)
                            .frame(width: 150)
                        TextField("Graduation Year", text: $endYear)
                            .frame(width: 180)
                    }
                }
            }

            
            HStack {
                Button() {
                    showAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .alert("Delete this education?", isPresented: $showAlert, actions: {
                    Button(role: .destructive) {
                        Task{ await deleteEducation() }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                })
                .tint(.red)

                Spacer()

                VStack(alignment: .trailing) {
                    if !message.isEmpty {
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .font(.default)
                            .foregroundStyle(Color(.red))
                    }
                    
                    HStack() {
                        Button("Cancel") { dismiss() }
                        Button(action: {
                            Task { await updateEducation() }
                        }, label: {
                            HStack(spacing: 10) {
                                if isLoading {
                                    ProgressView().controlSize(.small)
                                }
                                Text("Save")
                            }
                        })
                        .disabled(isLoading)
                        .shake(shakeTrigger)
                        .animation(.snappy, value: isLoading)
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }
        }
        .animation(.snappy, value: message.isEmpty)
        .padding(20)
    }
    
    private func updateEducation() async {
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let trimmedSchool = school.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDegree = degree.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedMajor  = major.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedSchool.isEmpty else {
                shakeTrigger += 1
                message = "School name is empty."
                return
            }
            
            guard !trimmedDegree.isEmpty else {
                shakeTrigger += 1
                message = "Degree is empty."
                return
            }
            
            guard !trimmedMajor.isEmpty else {
                shakeTrigger += 1
                message = "Major is empty."
                return
            }
            
            let trimmedStart = startYear.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedEnd   = endYear.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmedStart.isEmpty else {
                shakeTrigger += 1
                message = "Start Year is empty."
                return
            }
            
            guard !trimmedEnd.isEmpty else {
                shakeTrigger += 1
                message = "Graduation Year is empty."
                return
            }
            
            guard trimmedStart.count == 4 else {
                shakeTrigger += 1
                message = "Start year should be in the format: YYYY"
                return
            }
            guard trimmedEnd.count == 4 else {
                shakeTrigger += 1
                message = "Graduation year should be in the format: YYYY"
                return
            }
            
            guard let sy = Int(startYear) else {
                shakeTrigger += 1
                message = "Start year should be a number"
                return
            }
            
            guard let ey = Int(endYear) else {
                shakeTrigger += 1
                message = "Graduation year should be a number"
                return
            }
            
            guard sy < ey else {
                shakeTrigger += 1
                message = "Start year must be before the graduation year."
                return
            }
            
            let resp = try await profileService.updateEducation(
                token: token,
                id: education.id.uuidString,
                school: trimmedSchool,
                degree: trimmedDegree,
                major: trimmedMajor,
                startyear: sy,
                endyear: ey
            )
            
            let updated = Education(
                id: resp.id,
                school: resp.school.trimmingCharacters(in: .whitespacesAndNewlines),
                degree: resp.degree.trimmingCharacters(in: .whitespacesAndNewlines),
                major: resp.major.trimmingCharacters(in: .whitespacesAndNewlines),
                startyear: resp.startyear,
                endyear: resp.endyear
            )
            
            
            onSave(updated)
            dismiss()
        } catch let error as EducationError {
            switch error {
            case .educationnotfound:
                message = "Education not found"
                
            case .server:
                message = "Server error. Please try again."
            }
            shakeTrigger += 1
        } catch {
            message = "Something went wrong. Please try again."
            shakeTrigger += 1
        }
    }
    
    private func deleteEducation() async {
        guard let token = KeychainService.loadToken() else {
            message = "Missing token. Please log in again."
            shakeTrigger += 1
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await profileService.deleteEducation(token: token, id: education.id.uuidString)
            
            onDelete()
            dismiss()
        } catch let error as EducationError {
            switch error {
            case .educationnotfound:
                message = "Education not found"
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
    EditEducationView(
        education: Education(school: "Virginia Tech", degree: "Bachelor's", major: "Computer Science", startyear: 2024, endyear: 2028),
        onSave: { _ in },
        onDelete: {}
    )
}

