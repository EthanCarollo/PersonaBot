//
//  BotsViewModel.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI

public class BotsViewModel: ObservableObject {
    public static let shared = BotsViewModel()
    
    @Published var savedBots: [Bot] = []
    @Published var unsavedBots: [Bot] = []
    
    public func fetchBots() async {
        let botsRequest = await SupabaseService.shared.getUserSavedBots()
        if let fetchedBots = botsRequest {
            await MainActor.run {
                self.savedBots = fetchedBots
            }
        }
        
        if(self.savedBots.count == 0){
            self.savedBots = [Bot(id: UUID(), bot_public_id: "classic", name: "Assistant", description: "General assistant", icon: "person.fill")]
        }
        
        let botsRequestUnsaved = await SupabaseService.shared.getUserUnsavedBots()
        if let fetchedBots = botsRequestUnsaved {
            await MainActor.run {
                self.unsavedBots = fetchedBots
            }
        }
    }
}
