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
    
    func getUserUnsavedBots() async -> [Bot]? {
        do {
            let user = try await self.client.auth.user()
            
            
            let savedBots: [SavedBot] = try await self.client
                .from("saved_bots")
                .select("user_id, bot_id")
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            let savedBotIds = savedBots.map { $0.bot_id }
            
            let allBots: [Bot] = try await self.client
                .from("bots")
                .select("id, bot_public_id, name, description, icon")
                .execute()
                .value
            let unsavedBots = allBots.filter { !savedBotIds.contains($0.id) }
            
            return unsavedBots
        } catch {
            print("Error fetching unsaved bots: \(error)")
            return nil
        }
    }
    
    func getUserSavedBots() async -> [Bot]? {
        do {
            let user = try await self.client.auth.user()
            let saved_bots: [SavedBot] = try await self.client
                .from("saved_bots")
                .select("user_id, bot_id")
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            var bots: [Bot] = []
            for saved_bot in saved_bots {
                let bot: [Bot] = try await self.client
                  .from("bots")
                  .select("id, bot_public_id, name, description, icon")
                  .eq("id", value: saved_bot.bot_id)
                  .execute()
                  .value
                bots.append(bot.first!)
            }
            return bots
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteUserSavedBot(botId: UUID) async -> Bool {
        do {
            let user = try await self.client.auth.user()
            try await self.client
                .from("saved_bots")
                .delete()
                .eq("user_id", value: user.id)
                .eq("bot_id", value: botId)
                .execute()
            
            return true
        } catch {
            print("Erreur lors de la suppression du bot : \(error)")
            return false
        }
    }
    
    func getBots() async -> [Bot]? {
        do {
            let bots: [Bot] = try await self.client
              .from("bots")
              .select("""
                    id, 
                    bot_public_id, 
                    name, 
                    description, 
                    icon
                    """)
              .execute()
              .value
            print(bots)
            return bots
        } catch {
            print(error)
            return nil
        }
    }
    
    func getProfile() async -> Profile? {
        do {
            let user = try await self.client.auth.user()
            let profile: [Profile] = try await self.client
              .from("profiles")
              .select("id, username")
              .eq("id", value: user.id)
              .execute()
              .value
            return profile.first
        } catch {
            print(error)
            return nil
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

struct SavedBot : Decodable {
    let user_id: UUID
    let bot_id: UUID
}

struct Bot : Decodable, Identifiable, Hashable {
    let id: UUID
    let bot_public_id: String
    let name: String
    let description: String?
    let icon: String
}

struct Profile: Decodable {
    let id: UUID
    let username: String
}

enum AuthError: Error {
    case invalidCredentials
    case unknownError
}
