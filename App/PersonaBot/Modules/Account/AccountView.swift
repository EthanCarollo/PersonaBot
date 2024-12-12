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
    @ObservedObject var authViewModel = AuthViewModel.shared

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if authViewModel.isCheckingAuth {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                    .scaleEffect(2)
            } else if authViewModel.isAuthenticated {
                VStack(spacing: 20) {
                    // Profile section
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.neonGreen)
                        
                        HStack {
                            Text("Mon Compte")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(authViewModel.userRole.capitalizingFirstLetter())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        TextField("Nom d'utilisateur", text: $authViewModel.username)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .onSubmit {
                                authViewModel.updateUsername()
                            }
                    }
                    .padding(.top, 50)
                    
                    VStack(spacing: 15) {
                        AccountOptionButton(icon: "bubble.left.and.bubble.right", text: "Mes Bots", isPro: false, isEnabled: true) {
                            authViewModel.showMyBotsSheet = true
                        }
                        AccountOptionButton(icon: "person.badge.plus", text: "Créer un Bot", isPro: true, isEnabled: authViewModel.userRole == "pro") {
                            PostHogService.shared.CaptureEvent(event: "OpenCreateBotView")
                            authViewModel.showCreateBotSheet = true
                        }
                        AccountOptionButton(icon: "gear", text: "Paramètres", isPro: false, isEnabled: true) {
                            authViewModel.showSettingsSheet = true
                        }
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .sheet(isPresented: $authViewModel.showCreateBotSheet) {
                    CreateBotView()
                }
                .sheet(isPresented: $authViewModel.showMyBotsSheet) {
                    MyBotsView()
                }
                .sheet(isPresented: $authViewModel.showSettingsSheet) {
                    SettingsView()
                        .environmentObject(authViewModel)
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
                    
                    Button(action: { authViewModel.showAuthView = true }) {
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
                .padding(.bottom, 100)
                .sheet(isPresented: $authViewModel.showAuthView, onDismiss: {authViewModel.setUserInformation()}) {
                    AuthView()
                        .environmentObject(authViewModel)
                }
            }
            
            if authViewModel.isUpdatingUsername {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                    .scaleEffect(2)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.setUserInformation()
        }
        .alert(isPresented: $authViewModel.showUsernameUpdateAlert) {
            Alert(title: Text("Mise à jour du nom d'utilisateur"),
                  message: Text(authViewModel.usernameUpdateMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct AccountOptionButton: View {
    let icon: String
    let text: String
    let isPro: Bool
    let isEnabled: Bool
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
                
                if isPro {
                    Text("Pro")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .disabled(!isEnabled)
    }
}
