//
//  CreateBotViewModel.swift
//  PersonaBot
//
//  Created by eth on 09/12/2024.
//
import SwiftUI


class CreateBotViewModel: ObservableObject {
    @Published var botName = ""
    @Published var botDescription = ""
    @Published var publicId = ""
    @Published var knowledgeBase: [String] = []
    @Published var selectedIcon = "person.fill"
    
    let icons = ["person.fill", "brain.head.profile", "desktopcomputer", "fork.knife", "atom", "cross.case.fill", "leaf.fill"]
    
    func isFormValid() -> Bool {
        !botName.isEmpty && !botDescription.isEmpty && !publicId.isEmpty
    }
    
    func submitCreation() async -> Bool {
        PostHogService.shared.CaptureEvent(event: "CreationBotSubmit")
        guard isFormValid() else { return false }
        
        let newBot = BotCreable(
            name: botName,
            description: botDescription,
            publicId: publicId,
            knowledge: knowledgeBase,
            icon: selectedIcon
        )
        
        do {
            try await BackendService.shared.createBot(bot: newBot)
            PostHogService.shared.CaptureEvent(event: "CreationBotSuccessful")
            // Here you would typically send the newBot to your data store or API
            print("New bot created: \(newBot)")
            
            // Return true to indicate successful creation
            return true
        } catch {
            PostHogService.shared.CaptureEvent(event: "CreationBotError")
            print(error)
            return false
        }
        
    }
}
