//
//  AuthView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
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
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var result: Result<Void, Error>?
    @State private var showPassword = false
    @State private var isLoginMode = false
    @State private var keyboardHeight: CGFloat = 0
    
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
            
            VStack {
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
                    Text(isLoginMode ? "Log in" : "Sign up")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Login/Register toggle
                    HStack {
                        Text(isLoginMode ? "No account?" : "Already have an account?")
                            .foregroundColor(.white)
                        Button(isLoginMode ? "Sign Up" : "Log In") {
                            isLoginMode.toggle()
                        }
                        .foregroundColor(.green)
                    }
                    
                    // Form card
                    VStack(spacing: 1) {
                        if !isLoginMode {
                            // Name field
                            HStack(spacing: 15) {
                                Image(systemName: "person")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                TextField("Full Name", text: $name, prompt: Text("Full Name").foregroundColor(.gray))
                                    .textContentType(.name)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                        }
                        
                        // Email field
                        HStack(spacing: 15) {
                            Image(systemName: "envelope")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray))
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(isLoginMode ? 15 : 0, corners: [.topLeft, .topRight])
                        
                        // Password field
                        HStack(spacing: 15) {
                            Image(systemName: "lock")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Group {
                                if showPassword {
                                    TextField("", text: $password, prompt: Text("Password").foregroundColor(.gray))
                                } else {
                                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray))
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
                    
                    /*
                    // Forgot password
                    Button(action: {
                        // Handle forgot password
                    }) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(.white)
                            .underline()
                    }
                     */
                    
                    // Sign up/Login button
                    Button(action: isLoginMode ? loginButtonTapped : signUpButtonTapped) {
                        ZStack {
                            Text(isLoginMode ? "Log in" : "Sign up")
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
                            if isLoginMode {
                                Text("Successfully logged in.")
                                    .foregroundColor(.green)
                            } else {
                                Text("Check your inbox.")
                                    .foregroundColor(.green)
                            }
                        case .failure(let error):
                            switch(error){
                            case AuthError.invalidCredentials :
                                Text("Invalid Credentials")
                                    .foregroundColor(.red)
                            default :
                                Text(error.localizedDescription)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.vertical)
                Spacer(minLength: keyboardHeight > 0 ? 40 : 0)
                Spacer()
            }
            // Spacer(minLength: keyboardHeight > 0 ? 60 : 0)
        }
        .onOpenURL(perform: { url in
            Task {
                do {
                    try await SupabaseService.shared.client.auth.session(from: url)
                } catch {
                    self.result = .failure(error)
                }
            }
        })
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func signUpButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await SupabaseService.shared.client.auth.signUp(email: email, password: password,
                                                                    data: ["username": .string(name)],
                                                                    redirectTo: URL(string:"com.pragmatiiic.personabot://login-callback"))
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
    
    func loginButtonTapped() {
        Task {
            isLoading = true
            
            let authenticated = await SupabaseService.shared.login(email: email, password: password)
            if(authenticated == true){
                result = .success(())
                await BotsViewModel.shared.fetchBots()
                authViewModel.setUserInformation()
                isLoading = false
                dismiss()
            } else {
                authViewModel.isAuthenticated = false
                isLoading = false
                result = .failure(AuthError.invalidCredentials)
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

