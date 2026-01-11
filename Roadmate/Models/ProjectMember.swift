//
//  ProjectRole.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/9/26.
//


import Foundation

enum ProjectRole: String, Codable, CaseIterable, Identifiable {
    case owner, frontend, backend, fullstack, pm, qa
    var id: String { rawValue }

    var label: String {
        switch self {
        case .owner: return "Owner"
        case .frontend: return "Frontend"
        case .backend: return "Backend"
        case .fullstack: return "Full-stack"
        case .pm: return "Coordinator/PM"
        case .qa: return "QA"
        }
    }
}

struct ProjectMember: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var username: String
    var role: ProjectRole
}
