//
//  SessionState.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/8/26.
//


import Foundation
import SwiftUI
import Combine
import Observation

@MainActor
@Observable final class SessionState {
    // Persisted values
    @ObservationIgnored @AppStorage("session.userId") private var storedUserId: String = ""
    @ObservationIgnored @AppStorage("session.username") private var storedUsername: String = ""
    
    // Runtime-published values
    var isAuthenticated: Bool = false
    var username: String?
    var userID: String?
    
    init() {
        restore()
    }

    func login(userID: String, username: String, token: String) {
        storedUserId = userID
        storedUsername = username
        
        KeychainService.saveToken(token)
        
        self.userID = userID
        self.username = username
        self.isAuthenticated = true
    }

    func logout() {
        KeychainService.deleteToken()
        
        storedUsername = ""
        storedUserId = ""
        
        self.userID = nil
        self.username = nil
        self.isAuthenticated = false
    }
    
    func restore() {
        let token = KeychainService.loadToken()
        
        guard token != nil else {
            self.userID = nil
            self.username = nil
            self.isAuthenticated = false
            return
        }
        
        self.userID = storedUserId.isEmpty ? nil : storedUserId
        self.username = storedUsername.isEmpty ? nil : storedUsername
        self.isAuthenticated = true
    }
}

extension SessionState {
    static func preview(username: String = "preview-user") -> SessionState {
        let s = SessionState()
        s.username = username
        s.userID = UUID().uuidString
        s.isAuthenticated = true
        return s
    }
}

