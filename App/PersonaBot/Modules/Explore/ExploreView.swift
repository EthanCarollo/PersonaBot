//
//  ExploreView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI
import SwiftKeychainWrapper

struct Bot: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    var isSaved: Bool
}

class ExploreViewModel: ObservableObject {
    @Published var bots: [Bot]
    @Published var searchText: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = false
    
    init() {
        self.bots = [
            Bot(name: "Ugo sans H", description: "Assistant développeur SwiftUI sarcastique et passionné", icon: "terminal", isSaved: false),
            Bot(name: "Chef Michel", description: "Expert culinaire français, spécialiste de la cuisine traditionnelle", icon: "fork.knife", isSaved: false),
            Bot(name: "Prof. Einstein", description: "Tuteur de physique et mathématiques", icon: "function", isSaved: false),
            Bot(name: "Dr. Watson", description: "Assistant médical pour des conseils de santé généraux", icon: "cross.case", isSaved: false),
            Bot(name: "Eco Guide", description: "Conseiller en développement durable et écologie", icon: "leaf", isSaved: false)
        ]
        checkAuthentication()
    }
    
    func toggleSave(for bot: Bot) {
        if isAuthenticated {
            if let index = bots.firstIndex(where: { $0.id == bot.id }) {
                bots[index].isSaved.toggle()
            }
        }
    }
    
    var filteredBots: [Bot] {
        if searchText.isEmpty {
            return bots
        }
        return bots.filter { $0.name.localizedCaseInsensitiveContains(searchText) ||
                             $0.description.localizedCaseInsensitiveContains(searchText) }
    }
    
    func checkAuthentication() {
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
}

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showAuthAlert = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Explorer")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Rechercher un bot...", text: $viewModel.searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredBots) { bot in
                            BotCard(bot: bot, isAuthenticated: viewModel.isAuthenticated) {
                                if viewModel.isAuthenticated {
                                    viewModel.toggleSave(for: bot)
                                } else {
                                    withAnimation {
                                        showAuthAlert = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 72)
                }
                
                Spacer()
            }
            
            if showAuthAlert {
                CustomAlert(isPresented: $showAuthAlert, message: "Fonctionnalité réservée aux membres connectés")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showAuthAlert = false
                            }
                        }
                    }
            }
        }
    }
}


