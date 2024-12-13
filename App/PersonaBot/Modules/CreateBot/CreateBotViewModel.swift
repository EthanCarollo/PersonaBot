//
//  CreateBotViewModel.swift
//  PersonaBot
//
//  Created by eth on 09/12/2024.
//
import SwiftUI
import Combine


class CreateBotViewModel: ObservableObject {
    @Published var botName = ""
    @Published var botDescription = ""
    @Published var publicId = ""
    @Published var instruction = ""
    @Published var knowledgeBase: [String] = []
    @Published var selectedIcon = "person.fill"
    @Published var isValidPublicId: Bool = true
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        $publicId
            .dropFirst()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { self.sanitizePublicId($0) }
            .sink { [weak self] sanitizedId in
                self?.publicId = sanitizedId
                self?.validatePublicId()
            }
            .store(in: &cancellables)
    }

    private func sanitizePublicId(_ id: String) -> String {
        return id.lowercased().replacingOccurrences(of: " ", with: "")
    }

    private func validatePublicId() {
        isValidPublicId = !publicId.contains(" ")
    }

    func isFormValid() -> Bool {
        !botName.isEmpty &&
        !botDescription.isEmpty &&
        !publicId.isEmpty &&
        isValidPublicId &&
        !selectedIcon.isEmpty &&
        !knowledgeBase.isEmpty &&
        !instruction.isEmpty
    }
    
    let icons = ["person.fill", "brain.head.profile", "desktopcomputer", "fork.knife", "atom", "cross.case.fill", "leaf.fill"]
    
    func submitCreation() async -> Bool {
        PostHogService.shared.CaptureEvent(event: "CreationBotSubmit")
        guard isFormValid() else { return false }
        
        let newBot = BotCreable(
            name: botName,
            description: botDescription,
            publicId: publicId,
            knowledge: knowledgeBase,
            icon: selectedIcon,
            instruction: instruction
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
