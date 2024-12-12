//
//  ExploreViewModel.swift
//  PersonaBot
//
//  Created by eth on 09/12/2024.
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
