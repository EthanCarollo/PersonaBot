//
//  ChatView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Chat messages
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // Message input
                HStack(spacing: 15) {
                    TextField("Votre message...", text: $messageText)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(25)
                        .foregroundColor(.white)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.neonGreen)
                    }
                }
                .padding()
                .padding(.bottom, 80) // Increased padding for NavBar
            }
        }
        .navigationBarHidden(true)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = ChatMessage(id: UUID(), content: messageText, isUser: true)
        messages.append(newMessage)
        messageText = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = ChatMessage(id: UUID(), content: "Je suis là pour vous aider!", isUser: false)
            messages.append(response)
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.neonGreen : Color.white.opacity(0.1))
                .foregroundColor(message.isUser ? .black : .white)
                .cornerRadius(20)
                .shadow(color: message.isUser ? Color.neonGreen.opacity(0.3) : .clear, radius: 10)
            
            if !message.isUser { Spacer() }
        }
    }
}

