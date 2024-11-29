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
                botSelectionView
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
    
    private var botSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.bots) { bot in
                    Button(action: {
                        viewModel.selectedBot = bot
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.selectedBot?.id == bot.id ? Color.green.opacity(0.3) : Color.black)
                                    .frame(width: 60, height: 60)
                                Text(bot.icon)
                                    .font(.system(size: 30))
                            }
                            .overlay(
                                Circle()
                                    .stroke(viewModel.selectedBot?.id == bot.id ? Color.green : Color.gray, lineWidth: 2)
                            )
                            
                            Text(bot.name)
                                .font(.caption)
                                .foregroundColor(viewModel.selectedBot?.id == bot.id ? .green : .white)
                        }
                    }
                    .frame(width: 80)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16) // Ajout de padding en haut
        }
        .frame(height: 120) // Augmentation de la hauteur pour accommoder le padding supplémentaire
        .background(Color.black.edgesIgnoringSafeArea(.horizontal))
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

