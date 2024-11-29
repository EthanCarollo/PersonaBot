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
    @State private var username = ""
    @State private var isUpdatingUsername = false
    @State private var showUsernameUpdateAlert = false
    @State private var usernameUpdateMessage = ""
    
    @State private var showMyBotsSheet = false
    @State private var showSettingsSheet = false
    
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
                        
                        // Username TextField
                        TextField("Nom d'utilisateur", text: $username)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .onSubmit {
                                updateUsername()
                            }
                    }
                    .padding(.top, 50)
                    
                    // Account options
                    VStack(spacing: 15) {
                        AccountOptionButton(icon: "bubble.left.and.bubble.right", text: "Mes Bots") {
                            showMyBotsSheet = true
                        }
                        AccountOptionButton(icon: "gear", text: "Paramètres") {
                            showSettingsSheet = true
                        }
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .sheet(isPresented: $showMyBotsSheet) {
                    MyBotsView()
                }
                .sheet(isPresented: $showSettingsSheet) {
                    SettingsView()
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
            
            if isUpdatingUsername {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                    .scaleEffect(2)
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            checkAuthentication()
            setUsername()
        }
        .alert(isPresented: $showUsernameUpdateAlert) {
            Alert(title: Text("Mise à jour du nom d'utilisateur"),
                  message: Text(usernameUpdateMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    
    private func checkAuthentication() {
        isCheckingAuth = true
        Task {
            self.isAuthenticated = await SupabaseService.shared.isAuthenticated()
            isCheckingAuth = false
        }
    }
    
    private func setUsername(){
        Task {
            let profile = await SupabaseService.shared.getProfile()
            if let userProfile = profile {
                username = userProfile.username
            }
        }
    }
    
    private func updateUsername() {
        isUpdatingUsername = true
        Task {
            do {
                try await SupabaseService.shared.updateUsername(newUsername: username)
                DispatchQueue.main.async {
                    self.isUpdatingUsername = false
                    self.usernameUpdateMessage = "Nom d'utilisateur mis à jour avec succès"
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
    
    private func login() async {
        
    }
    
    private func logout() {
        Task {
            await SupabaseService.shared.logout()
            self.isAuthenticated = false
        }
    }
}

struct AccountOptionButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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


