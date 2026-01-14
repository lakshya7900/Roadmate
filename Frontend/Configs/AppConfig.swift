//
//  AppConfig.swift
//  Roadmate
//
//  Created by Lakshya Agarwal on 1/12/26.
//

import Foundation


enum AppConfig {
    static let apiBaseURL: URL = {
        let key = "API_BASE_URL"
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              let url = URL(string: raw)
        else {
            fatalError("Missing/invalid \(key). Check Target → Info and xcconfig.")
        }
        return url
    }()
}

