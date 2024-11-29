//
//  ChatViewModel.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var bots: [Bot] = []
    @Published var selectedBot: Bot?
    var scrollProxy: ScrollViewProxy?
    
    init() {
        fetchBots()
    }
    
    func fetchBots() {
        // Simulated API call to fetch bots
        // In a real app, you would make an actual network request here
        self.bots = [
            Bot(id: UUID(), bot_public_id: "classic", name: "Assistant", description: "General assistant", icon: "person.fill"),
        ]
        self.selectedBot = self.bots.first
        
        Task {
            let botsRequest = await SupabaseService.shared.getUserSavedBots()
            if let fetchedBots = botsRequest {
                await MainActor.run {
                    self.bots = self.bots + fetchedBots
                }
            }
        }
    }
    
    func onAppear(){
        fetchBots()
    }
    
    func sendMessage() {
        guard !messageText.isEmpty, let selectedBot = selectedBot else { return }
        let newMessage = ChatMessage(id: UUID(), content: messageText, isUser: true)
        messages.append(newMessage)
        
        let currentMessage = messageText
        messageText = ""
        isLoading = true
        
        Task {
            do {
                let response = try await sendMessageToBackend(message: currentMessage, botPublicId: selectedBot.bot_public_id)
                print(response)
                await MainActor.run {
                    let aiResponse = ChatMessage(id: UUID(), content: response, isUser: false)
                    messages.append(aiResponse)
                    isLoading = false
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                await MainActor.run {
                    let errorMessage = ChatMessage(id: UUID(), content: "Désolé, une erreur s'est produite. Veuillez réessayer.", isUser: false)
                    messages.append(errorMessage)
                    isLoading = false
                }
            }
        }
    }
    
    private func sendMessageToBackend(message: String, botPublicId: String) async throws -> String {
        // Déterminer l'URL en fonction de l'ID du bot, si c'est le classic, alors on va just chatter normalement
        let endpoint = botPublicId == "classic" ? "/chat" : "/chat_with_bot"
        guard let url = URL(string: Config.backendURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["text": message, "bot_public_id": botPublicId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
        return response.response
    }

}

