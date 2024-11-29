//
//  ChatBubble.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI

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
