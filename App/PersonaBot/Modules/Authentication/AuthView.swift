//
//  AuthView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI
import Supabase
import SwiftKeychainWrapper

struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var result: Result<Void, Error>?
    @State private var showPassword = false
    @State private var isLoginMode = false
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Background waves
            ForEach(0..<15) { i in
                OrganicWave(waveOffset: Double(i) * 20)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    .rotationEffect(Angle(degrees: 20))
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .imageScale(.large)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Logo
                    Image("Bot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.green.opacity(0.5), radius: 20)
                    
                    // Title
                    Text(isLoginMode ? "Connecte-toi" : "Inscris-toi")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Login/Register toggle
                    HStack {
                        Text(isLoginMode ? "Pas de compte ?" : "Déjà un compte ?")
                            .foregroundColor(.white)
                        Button(isLoginMode ? "Inscris-toi" : "Connecte-toi") {
                            isLoginMode.toggle()
                        }
                        .foregroundColor(.green)
                    }
                    
                    // Form card
                    VStack(spacing: 1) {
                        if !isLoginMode {
                            // Name field
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.green)
                                TextField("Nom complet", text: $name)
                                    .textContentType(.name)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                        }
                        
                        // Email field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.green)
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(isLoginMode ? 15 : 0, corners: [.topLeft, .topRight])
                        
                        // Password field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.green)
                            Group {
                                if showPassword {
                                    TextField("Mot de passe", text: $password)
                                } else {
                                    SecureField("Mot de passe", text: $password)
                                }
                            }
                            .textContentType(.password)
                            .foregroundColor(.black)
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.horizontal)
                    
                    // Forgot password
                    Button(action: {
                        // Handle forgot password
                    }) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(.white)
                            .underline()
                    }
                    
                    // Sign up/Login button
                    Button(action: isLoginMode ? loginButtonTapped : signUpButtonTapped) {
                        ZStack {
                            Text(isLoginMode ? "Se connecter" : "M'inscrire")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal)
                    }
                    .disabled(isLoading)
                    
                    if let result {
                        switch result {
                        case .success:
                            Text("Vérifiez votre boîte mail.")
                                .foregroundColor(.green)
                        case .failure(let error):
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .onOpenURL(perform: { url in
            Task {
                do {
                    try await supabase.auth.session(from: url)
                } catch {
                    self.result = .failure(error)
                }
            }
        })
    }
    
    func signUpButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await supabase.auth.signUp(email: email, password: password)
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
    
    func loginButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let authResponse = try await supabase.auth.signIn(email: email, password: password)
                let accessToken = authResponse.accessToken
                // Sauvegarder le token JWT dans le keychain
                let saveSuccessful: Bool = KeychainWrapper.standard.set(accessToken, forKey: "PersonaBotJWTToken")
                if saveSuccessful {
                    print("JWT token sauvegardé avec succès")
                } else {
                    print("Échec de la sauvegarde du JWT token")
                }
                result = .success(())
                isAuthenticated = true
                dismiss()
            } catch {
                result = .failure(error)
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}