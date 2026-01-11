import Foundation

struct Project: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var members: [ProjectMember]
    var tasks: [TaskItem]
    var createdAt: Date = Date()
}
