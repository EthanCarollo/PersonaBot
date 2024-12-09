//
//  AuthViewModel.swift
//  PersonaBot
//
//  Created by eth on 09/12/2024.
//


import SwiftUI
import SwiftKeychainWrapper
import Supabase

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        isCheckingAuth = true
        Task {
            self.isAuthenticated = await SupabaseService.shared.isAuthenticated()
            DispatchQueue.main.async {
                self.isCheckingAuth = false
            }
        }
    }
}