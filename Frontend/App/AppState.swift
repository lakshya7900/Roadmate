//
//  AppState.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/9/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
@Observable final class AppState {
    enum Route: Hashable {
        case profile
        case allProjects
        case project(UUID)
        case planner
    }

    var selection: Route? = .profile
}
