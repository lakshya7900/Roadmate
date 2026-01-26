//
//  ProfileService.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/12/26.
//

import Foundation

enum APIError: Error {
    case badStatus(Int, String)
}

enum SkillError: Error {
    case skillNotFound
    case serverError
}

enum EducationError: Error {
    case educationNotFound
    case serverError
}

struct AddSkillRequest: Encodable {
    let name: String
    let proficiency: Int
}

struct UpdateSkillRequest: Encodable {
    let id: String
    let proficiency: Int
}

struct AddEducationRequest: Encodable {
    let school: String
    let degree: String
    let major: String
    let startyear: Int
    let endyear: Int
}

struct UpdateEducationRequest: Encodable {
    let id: String
    let school: String
    let degree: String
    let major: String
    let startyear: Int
    let endyear: Int
}

final class ProfileService {
    func getProfile(token: String) async throws -> UserProfile {
        let url = AppConfig.apiBaseURL.appendingPathComponent("/me/profile")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        
        guard code == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.badStatus(code, body)
        }
        
        return try JSONDecoder().decode(UserProfile.self, from: data)    }

    func updateProfile(token: String, name: String, headline: String, bio: String) async throws {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let h = headline.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        let url = AppConfig.apiBaseURL.appendingPathComponent("/me/profile")
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = ["name": n, "headline": h, "bio": b]
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        if code != 200 {
            print("Update profile failed:", code, String(data: data, encoding: .utf8) ?? "")
            throw URLError(.badServerResponse)
        }
    }

    func addSkill(token: String, name: String, proficiency: Int) async throws -> Skill {
        let url = AppConfig.apiBaseURL.appendingPathComponent("/me/skills")
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = AddSkillRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            proficiency: proficiency
        )
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as! HTTPURLResponse).statusCode
        
        guard code == 200 else {
            throw APIError.badStatus(code, String(data: data, encoding: .utf8) ?? "")
        }
        
        let dto = try JSONDecoder().decode(Skill.self, from: data)
        return dto
    }
    
    func updateSkill(token:String, id: String, proficiency: Int) async throws -> Skill {
        let url = AppConfig.apiBaseURL.appendingPathComponent("/me/skills")
        
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = UpdateSkillRequest(id: id, proficiency: proficiency)
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.server
        }
        
        switch http.statusCode {
        case 200:
            let dto = try JSONDecoder().decode(Skill.self, from: data)
            return dto

        case 404:
            throw SkillError.skillNotFound

        default:
            throw SkillError.serverError
        }
    }
    
    func deleteSkill(token:String, id: UUID) async throws {
        let url = AppConfig.apiBaseURL
            .appendingPathComponent("/me/skills/\(id.uuidString.lowercased())")
        
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.server
        }
        
        switch http.statusCode {
        case 200:
            return
        case 404:
            throw SkillError.skillNotFound

        default:
            throw SkillError.serverError
        }
    }
    
    func addEducations(token: String, school: String, degree: String, major:String, startyear: Int, endyear: Int) async throws -> Education {
        let url = AppConfig.apiBaseURL.appendingPathComponent("/me/educations")
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = AddEducationRequest(
            school: school,
            degree: degree,
            major: major,
            startyear: startyear,
            endyear: endyear
        )
        req.httpBody = try? JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as! HTTPURLResponse).statusCode
        
        guard code == 200 else {
            throw APIError.badStatus(code, String(data: data, encoding: .utf8) ?? "")
        }
        
        let dto = try JSONDecoder().decode(Education.self, from: data)
        return dto
    }
    
    func updateEducation(token:String, id: String, school: String, degree: String, major:String, startyear: Int, endyear: Int) async throws -> Education {
        let url = AppConfig.apiBaseURL.appendingPathComponent("/me/educations")
        
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = UpdateEducationRequest(
            id: id,
            school: school,
            degree: degree,
            major: major,
            startyear: startyear,
            endyear: endyear
        )
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.server
        }
        
        switch http.statusCode {
        case 200:
            let dto = try JSONDecoder().decode(Education.self, from: data)
            return dto

        case 404:
            throw EducationError.educationNotFound

        default:
            throw EducationError.serverError
        }
    }
    
    func deleteEducation(token:String, id: UUID) async throws {
        let url = AppConfig.apiBaseURL
            .appendingPathComponent("/me/educations\(id.uuidString.lowercased())")
        
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw AuthError.server
        }
        
        switch http.statusCode {
        case 200:
            return
        case 404:
            throw EducationError.educationNotFound

        default:
            throw EducationError.serverError
        }
    }
}
