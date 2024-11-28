//
//  ChatView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI
import Combine

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                chatMessagesView.padding(.top, 16)
                messageInputView(geometry: geometry)
                Spacer(minLength: keyboardHeight > 0 ? keyboardHeight - 4 : 78)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onChange(of: isFocused) { focused in
                if focused {
                    scrollToBottom(delay: 0.5)
                }
            }
            .onAppear {
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
        }
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                            .padding(.bottom, 20)
                    }
                    Color.clear.frame(height: 60)
                }
                .padding()
            }
            .onChange(of: viewModel.messages) { _ in
                scrollToBottom()
            }
            .onAppear {
                viewModel.scrollProxy = proxy
            }
        }
    }
    
    private func messageInputView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            HStack(spacing: 15) {
                TextField("Votre message...", text: $viewModel.messageText)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .focused($isFocused)
                
                sendButton
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.8))
        }
        .padding(.bottom, geometry.safeAreaInsets.bottom)
    }
    
    private var sendButton: some View {
        Button(action: viewModel.sendMessage) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.isLoading || viewModel.messageText.isEmpty ? .gray : .neonGreen)
                
                Text("Envoyer")
                    .font(.caption)
                    .foregroundColor(viewModel.isLoading || viewModel.messageText.isEmpty ? .gray : .neonGreen)
            }
        }
        .disabled(viewModel.isLoading || viewModel.messageText.isEmpty)
        .frame(width: 60)
    }
    
    private func scrollToBottom(delay: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                viewModel.scrollProxy?.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            }
        }
    }
    
    private func setupKeyboardObservers() {
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
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    var scrollProxy: ScrollViewProxy?
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = ChatMessage(id: UUID(), content: messageText, isUser: true)
        messages.append(newMessage)
        
        let currentMessage = messageText
        messageText = ""
        isLoading = true
        
        Task {
            do {
                let response = try await sendMessageToBackend(message: currentMessage)
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
    
    private func sendMessageToBackend(message: String) async throws -> String {
        guard let url = URL(string: Config.backendURL + "/chat") else {
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

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

