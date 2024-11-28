//
//  AccountView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI
import SwiftKeychainWrapper
import Supabase

struct AccountView: View {
    @Binding var isAuthenticated: Bool
    @Binding var showAuthView: Bool
    @State private var isCheckingAuth = true
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            if isCheckingAuth {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                    .scaleEffect(2)
            } else if isAuthenticated {
                VStack(spacing: 20) {
                    // Profile section
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.neonGreen)
                        
                        Text("Mon Compte")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                    
                    // Account options
                    VStack(spacing: 15) {
                        AccountOptionButton(icon: "gear", text: "Paramètres")
                        AccountOptionButton(icon: "bell", text: "Notifications")
                        AccountOptionButton(icon: "lock", text: "Confidentialité")
                        AccountOptionButton(icon: "questionmark.circle", text: "Aide")
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // Logout button
                    Button(action: logout) {
                        Text("Déconnexion")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 100) // Increased to account for NavBar
                }
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.neonGreen)
                    
                    Text("Connectez-vous pour accéder à votre compte")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: { showAuthView = true }) {
                        Text("Se connecter")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.neonGreen)
                            .cornerRadius(30)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 100) // Increased to account for NavBar
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: checkAuthentication)
    }
    
    private func checkAuthentication() {
        isCheckingAuth = true
        if KeychainWrapper.standard.string(forKey: "PersonaBotJWTToken") != nil {
            Task {
                do {
                    _ = try await supabase.auth.user()
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.isCheckingAuth = false
                    }
                } catch {
                    print("Error checking authentication: \(error)")
                    DispatchQueue.main.async {
                        self.isAuthenticated = false
                        self.isCheckingAuth = false
                    }
                }
            }
        } else {
            isAuthenticated = false
            isCheckingAuth = false
        }
    }
    
    private func logout() {
        Task {
            do {
                try await supabase.auth.signOut()
                KeychainWrapper.standard.removeObject(forKey: "PersonaBotJWTToken")
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
            } catch {
                print("Error logging out: \(error)")
            }
        }
    }
}

struct AccountOptionButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.neonGreen)
                    .frame(width: 30)
                
                Text(text)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
}

