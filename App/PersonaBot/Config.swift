//
//  Config.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import Foundation

struct Config {
    static let backendURL = "https://uos000wc0ccg88s4cwws004g.ethan-folio.fr"
    static let POSTHOG_API_KEY = "phc_tfRHQFzFKLKzYrDCEkqKfJ8RzbwclHkkVR3404Fk8xA"
    static let POSTHOG_HOST = "https://eu.i.posthog.com"
    static var appVersion: String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            return "\(version)"
        }
}

