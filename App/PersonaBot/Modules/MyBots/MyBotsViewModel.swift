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
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    init() {
        BotsViewModel.shared.$unsavedBots
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
    }
    
    func fetchBots(showLoad: Bool = true) async {
        await MainActor.run {
            if(showLoad) {
                isLoading = true
            }
        }
        await BotsViewModel.shared.fetchBots()
        DispatchQueue.main.async { [weak self] in
            self?.savedBots = BotsViewModel.shared.savedBots
            if(showLoad) {
                self?.isLoading = false
            }
        }
    }
    
    func deleteBot(botId: UUID) async {
        DispatchQueue.main.async { [weak self] in
            self?.savedBots.removeAll { $0.id == botId }
        }
        let resultBot = await SupabaseService.shared.deleteUserSavedBot(botId: botId)
        if resultBot == true{
            print("Can create bot")
        } else {
            print("Cannot create bot")
        }
        await fetchBots(showLoad: false)
    }
}


