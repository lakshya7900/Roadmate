import Foundation
import SwiftUI

@MainActor
final class ProjectStore: ObservableObject {
    @Published var projects: [Project] = []

    private let fileURL: URL

    init(username: String) {
        let safe = username.replacingOccurrences(of: "[^a-zA-Z0-9_-]+", with: "-", options: .regularExpression)
        self.fileURL = ProjectStore.makeFileURL(filename: "projects-\(safe).json")

        if let loaded = ProjectStore.load(from: fileURL) {
            self.projects = loaded
        } else {
            self.projects = []
            save()
        }
    }

    func save() {
        ProjectStore.save(projects, to: fileURL)
    }

    func upsert(_ project: Project) {
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
        } else {
            projects.insert(project, at: 0)
        }
        save()
    }

    func delete(_ projectId: UUID) {
        projects.removeAll { $0.id == projectId }
        save()
    }

    // MARK: - File helpers
    private static func makeFileURL(filename: String) -> URL {
        let fm = FileManager.default
        let base = (try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fm.temporaryDirectory

        let folder = base.appendingPathComponent("Roadmate", isDirectory: true)
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(filename)
    }

    private static func load(from url: URL) -> [Project]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Project].self, from: data)
    }

    private static func save(_ projects: [Project], to url: URL) {
        guard let data = try? JSONEncoder().encode(projects) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
