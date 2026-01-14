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

struct ProfileResponse: Decodable {
    let username: String
    let name: String
    let headline: String
    let bio: String
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
        
        let dto = try JSONDecoder().decode(ProfileResponse.self, from: data)
        
        var profile = UserProfile.defaultProfile(for: dto.username)
        profile.name = dto.name
        profile.headline = dto.headline
        profile.bio = dto.bio
        return profile
    }

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


}
