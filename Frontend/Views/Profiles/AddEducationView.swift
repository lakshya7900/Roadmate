//
//  AddEducationView.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/11/26.
//

import SwiftUI

struct AddEducationView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Education) -> Void
    
    @State private var profileServivce = ProfileService()

    @State private var school : String = ""
    @State private var degree : String = ""
    @State private var major : String = ""
    
    @State private var startYear: String = ""
    @State private var endYear: String = ""
    
    // UI state
    @State private var message: String = ""
    @State private var isLoading = false
    @State private var shakeTrigger: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Education")
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

            VStack(alignment: .trailing) {
                if !message.isEmpty {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .font(.default)
                        .foregroundStyle(Color(.red))
                }
                
                HStack {
                    Spacer()
                    Button("Cancel") { dismiss() }
                    Button(action: {
                        Task { await addEducation() }
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
        .animation(.snappy, value: message.isEmpty)
        .padding(20)
    }
    
    private func addEducation() async {
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
            
            let resp = try await profileServivce.addEducations(
                token: token,
                school: trimmedSchool,
                degree: trimmedDegree,
                major: trimmedMajor,
                startyear: sy,
                endyear: ey
            )
            
            let added = Education(
                id: resp.id,
                school: resp.school,
                degree: resp.degree,
                major: resp.major,
                startyear: resp.startyear,
                endyear: resp.endyear
            )
            
            onAdd(added)
            dismiss()
        } catch let APIError.badStatus(code, body) {
            if code == 409 {
                shakeTrigger += 1
                message = "Education already exists."
            } else {
                shakeTrigger += 1
                message = "Failed to add education (\(code))."
                print("AddSkill error body:", body)
            }
        } catch {
            shakeTrigger += 1
            message = "Failed to add education."
            print("AddSkill error:", error)
        }
    }
}

#Preview {
    AddEducationView { _ in }
        .frame(width: 550, height: 300)
}
