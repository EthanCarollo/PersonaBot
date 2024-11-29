//
//  MyBotsViewModel.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import Combine
import SwiftUI

class MyBotsViewModel: ObservableObject {
    @Published var savedBots: [Bot] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    var filteredBots: [Bot] {
        if searchText.isEmpty {
            return savedBots
        } else {
            return savedBots.filter { $0.name.lowercased().contains(searchText.lowercased())  }
        }
    }
    
    func fetchBots() async {
        await MainActor.run {
            isLoading = true
        }
        await BotsViewModel.shared.fetchBots()
        DispatchQueue.main.async { [weak self] in
            self?.savedBots = BotsViewModel.shared.savedBots
            self?.isLoading = false
        }
    }
    
    func deleteBot(botId: UUID) async {
        DispatchQueue.main.async { [weak self] in
            self?.savedBots.removeAll { $0.id == botId }
        }
        await SupabaseService.shared.deleteUserSavedBot(botId: botId)
        await fetchBots()
    }
}


