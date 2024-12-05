//
//  ChatView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if viewModel.isSelectingBot {
                    botSelectionView
                } else {
                    chatView(geometry: geometry)
                }
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
        ScrollView {
            LazyVStack(spacing: 16) {
                Text("Select an AI to chat with")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                ForEach(BotsViewModel.shared.savedBots) { bot in
                    Button(action: {
                        viewModel.selectBot(bot)
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: bot.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            
                            Text(bot.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.green)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
    
    private func chatView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            chatHeader
            chatMessagesView.padding(.top, 8)
            messageInputView(geometry: geometry)
            Spacer(minLength: keyboardHeight > 0 ? keyboardHeight - 4 : 78)
        }
    }
    
    private var chatHeader: some View {
        ZStack {
            HStack {
                Button(action: {
                    viewModel.isSelectingBot = true
                    viewModel.selectedBot = nil
                    viewModel.messages = []
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.green)
                        Text("Back")
                            .foregroundColor(.green)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            
            if let selectedBot = viewModel.selectedBot {
                Text(selectedBot.name)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 26)
        .frame(height: 44)
        .background(Color.black.opacity(0.8))
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.messages) { message in
                        chatBubble(for: message)
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
    
    private func chatBubble(for message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            Text(message.content)
                .padding(12)
                .background(message.isUser ? Color.green.opacity(0.8) : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(16)
            if !message.isUser {
                Spacer()
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
                    .foregroundColor(viewModel.isLoading || viewModel.messageText.isEmpty ? .gray : .green)
                
                Text("Envoyer")
                    .font(.caption)
                    .foregroundColor(viewModel.isLoading || viewModel.messageText.isEmpty ? .gray : .green)
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

