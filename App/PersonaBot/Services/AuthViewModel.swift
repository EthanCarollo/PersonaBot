//
//  AuthViewModel.swift
//  PersonaBot
//
//  Created by eth on 09/12/2024.
//


import SwiftUI
import SwiftKeychainWrapper
import Supabase

// REFACTOR IT TO A SERVICE ITS REALLY WEIRD ACTUALLY
class AuthViewModel: ObservableObject {
    public static let shared = AuthViewModel()
    
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    
    @Published var isUpdatingUsername = false
    @Published var usernameUpdateMessage = ""
    
    @Published var showAuthView = false
    @Published var showMyBotsSheet = false
    @Published var showCreateBotSheet = false
    @Published var showSettingsSheet = false
    @Published var showUsernameUpdateAlert = false
    
    @Published var userRole: String = "free"
    @Published var username = ""
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        DispatchQueue.main.async {
            self.isCheckingAuth = true
        }
        
        Task {
            let supaIsAuthenticated = await SupabaseService.shared.isAuthenticated()
            DispatchQueue.main.async {
                self.isAuthenticated = supaIsAuthenticated
                self.isCheckingAuth = false
            }
        }
    }
    
    func setUserInformation() {
        self.isCheckingAuth = true;
        Task {
            let profile = await SupabaseService.shared.getProfile()
            DispatchQueue.main.async {
                self.isCheckingAuth = false;
                if let userProfile = profile {
                    self.showAuthView = false
                    self.isAuthenticated = true
                    self.username = userProfile.username
                    self.userRole = userProfile.role
                }
            }
        }
    }
    
    func updateUsername() {
        self.isUpdatingUsername = true
        Task {
            do {
                try await SupabaseService.shared.updateUsername(newUsername: self.username)
                DispatchQueue.main.async {
                    self.isUpdatingUsername = false
                    self.usernameUpdateMessage = "Nom d'utilisateur mis à jour avec succès"
                    self.showUsernameUpdateAlert = true
                }
            } catch {
                print("Error updating username: \(error)")
                DispatchQueue.main.async {
                    self.isUpdatingUsername = false
                    self.usernameUpdateMessage = "Erreur lors de la mise à jour du nom d'utilisateur"
                    self.showUsernameUpdateAlert = true
                }
            }
        }
    }
}
