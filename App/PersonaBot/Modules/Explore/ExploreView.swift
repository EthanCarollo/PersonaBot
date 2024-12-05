//
//  ExploreView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import Combine
import SwiftUI
import SwiftKeychainWrapper

class ExploreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var isCheckingAuth: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.checkAuthentication()
        
        BotsViewModel.shared.$unsavedBots
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    var filteredBots: [Bot] {
        if searchText.isEmpty {
            return BotsViewModel.shared.unsavedBots
        }
        return BotsViewModel.shared.unsavedBots.filter {
            if let botDescription = $0.description {
                return $0.name.localizedCaseInsensitiveContains(searchText) ||
                botDescription.localizedCaseInsensitiveContains(searchText)
            } else {
                return $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func saveBot(bot: Bot) {
        PostHogService.shared.CaptureEvent(event: "SaveBot")
        print("save bot : \(bot)")
        Task {
            try await BackendService.shared.saveBot(botId: bot.id)
        }
        BotsViewModel.shared.unsavedBots.removeAll { $0.id == bot.id }
        if(BotsViewModel.shared.savedBots.first?.bot_public_id == "classic"){
            BotsViewModel.shared.savedBots = [bot]
        } else {
            BotsViewModel.shared.savedBots.append(bot)
        }
    }
    
    func checkAuthentication() {
        isCheckingAuth = true
        if KeychainWrapper.standard.string(forKey: "PersonaBotJWTToken") != nil {
            Task {
                do {
                    _ = try await SupabaseService.shared.client.auth.user()
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tint(.neonGreen)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredBots) { bot in
                                BotCard(bot: bot, iconAction: "bookmark", isAuthenticated: viewModel.isAuthenticated, onAction: {
                                    
                                    do {
                                        viewModel.saveBot(bot: bot)
                                    } catch {
                                        print(error)
                                    }
                                    
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 72)
                    }
                }
                
                
                
                Spacer()
            }.onAppear(perform: {
                Task {
                    await BotsViewModel.shared.fetchBots()
                }
            })
            
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
