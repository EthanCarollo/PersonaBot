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
    @State private var isLoading = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Chat messages
                    ScrollViewReader { scrollView in
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: messages) { _ in
                            withAnimation {
                                scrollView.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                    
                    // Message input
                    HStack(spacing: 15) {
                        TextField("Votre message...", text: $messageText)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(25)
                            .foregroundColor(.white)
                            .focused($isFocused)
                        
                        Button(action: sendMessage) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.neonGreen))
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color.neonGreen)
                            }
                        }
                        .disabled(isLoading || messageText.isEmpty)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .animation(.easeOut(duration: 0.16), value: keyboardHeight)
                    .offset(y: -keyboardHeight)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    keyboardHeight = keyboardRectangle.height
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = ChatMessage(id: UUID(), content: messageText, isUser: true)
        messages.append(newMessage)
        
        let currentMessage = messageText
        messageText = ""
        isLoading = true
        
        Task {
            do {
                let response = try await sendMessageToBackend(message: currentMessage)
                DispatchQueue.main.async {
                    let aiResponse = ChatMessage(id: UUID(), content: response, isUser: false)
                    messages.append(aiResponse)
                    isLoading = false
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    let errorMessage = ChatMessage(id: UUID(), content: "Désolé, une erreur s'est produite. Veuillez réessayer.", isUser: false)
                    messages.append(errorMessage)
                    isLoading = false
                }
            }
        }
    }
    
    private func sendMessageToBackend(message: String) async throws -> String {
        guard let url = URL(string: "\(Config.backendURL)/chat") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["text": message]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
        return response.response
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

struct BackendResponse: Codable {
    let response: String
}


