import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum Route: Hashable {
        case profile
        case allProjects
        case project(UUID)
        case planner
    }

    @Published var selection: Route? = .allProjects
}
