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
    @Published var selectedBot: Bot? = nil
    @Published var isSelectingBot = true
    @Published var canSendMessage: Bool = true
    var scrollProxy: ScrollViewProxy?
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
    
    func selectBot(_ bot: Bot) {
        selectedBot = bot
        isSelectingBot = false
        messages = []
        Task {
            let chatMessages = await SupabaseService.shared.getBotDiscussion(botPublicId: bot.bot_public_id)
            guard let _messages: [ChatMessage] = chatMessages else {
                return
            }
            await MainActor.run {
                messages = _messages
            }
        }
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
                let response = try await BackendService.shared.sendMessageToBackend(message: currentMessage, botPublicId: selectedBot.bot_public_id)
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
}

