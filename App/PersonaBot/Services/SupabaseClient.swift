//
//  SupabaseClient.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import Foundation
import Supabase
import SwiftKeychainWrapper

// Rename file
class SupabaseService {
    static let shared = SupabaseService()
    
    public let client: SupabaseClient

    private init() {
        let supabaseUrl = URL(string: "https://caevfrlaqsgjrbkyhizp.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhZXZmcmxhcXNnanJia3loaXpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI3OTYxNzQsImV4cCI6MjA0ODM3MjE3NH0.fKMfNlN1kONrlgunhWPXluU-fNEFC6V-Eom2pGysaK8"
        self.client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
    
    func isAuthenticated() async -> Bool {
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "PersonaBotJWTToken") else {
            return false
        }
        
        var isAuthenticated = false
        do {
            try await self.client.auth.user()
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
        
        return isAuthenticated
    }
    
    func login(email: String, password: String) async -> Bool {
        do {
            let authResponse = try await self.client.auth.signIn(email: email, password: password)
            let accessToken = authResponse.accessToken
            // Sauvegarder le token JWT dans le keychain
            let saveSuccessful: Bool = KeychainWrapper.standard.set(accessToken, forKey: "PersonaBotJWTToken")
            if saveSuccessful {
                print("JWT token sauvegardé avec succès")
                return true
            } else {
                print("Échec de la sauvegarde du JWT token")
                return false
            }
        } catch {
            return false
        }
    }
    
    func logout() async {
        do {
            try await SupabaseService.shared.client.auth.signOut()
            KeychainWrapper.standard.removeObject(forKey: "PersonaBotJWTToken")
        } catch {
            print("Error logging out: \(error)")
        }
    }

    /// Updates the username in the profiles table.
    func updateUsername(newUsername: String) {
        Task {
            struct UpdateProfileParams: Encodable {
              let username: String

              enum CodingKeys: String, CodingKey {
                case username
              }
            }
            
            let updates: UpdateProfileParams = UpdateProfileParams(
                username: newUsername
              )

            do {
                let currentUser = try await self.client.auth.session.user
                try await self.client
                    .from("profiles")
                    .update(updates)
                    .eq("id", value: currentUser.id)
                    .execute()
            } catch {
                debugPrint(error)
            }
        }
    }
}

enum AuthError: Error {
    case invalidCredentials
    case unknownError
}
