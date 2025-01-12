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
        VStack(spacing: 0) {
            // Safe area top color
            Color.black
                .frame(height: 0)
                .edgesIgnoringSafeArea(.top)
            
            // Main content
            VStack(spacing: 0) {
                if viewModel.selectedBot == nil {
                    // Bot Selection View
                    VStack(spacing: 0) {
                        // Header
                        Text("Select a Bot")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        
                        // Bot List
                        if BotsViewModel.shared.savedBots.isEmpty {
                            VStack(spacing: 12) {
                                Spacer()
                                Text("No bots available")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                Text("Add bots from the Explore tab")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(BotsViewModel.shared.savedBots) { bot in
                                        BotCard(bot: bot, iconAction: "chevron.right", isAuthenticated: true) {
                                            withAnimation {
                                                viewModel.selectBot(bot)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 96)
                            }
                        }
                    }
                } else {
                    // Chat View
                    VStack(spacing: 0) {
                        // Chat Header
                        HStack {
                            Button(action: {
                                withAnimation {
                                    viewModel.selectedBot = nil
                                    viewModel.messages = []
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.green)
                                    .imageScale(.large)
                            }
                            
                            Text(viewModel.selectedBot?.name ?? "Chat")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.black)
                        
                        // Messages
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(viewModel.messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                            .padding(.bottom, 16)
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: viewModel.messages) { _ in
                                withAnimation {
                                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                }
                            }
                        }
                        
                        // Input Area
                        VStack(spacing: 0) {
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            HStack(spacing: 12) {
                                TextField("Type a message...", text: $viewModel.messageText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($isFocused)
                                
                                Button(action: viewModel.sendMessage) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(!viewModel.messageText.isEmpty ? .green : .gray)
                                }
                                .disabled(viewModel.messageText.isEmpty)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : 76)
                            .background(Color.black)
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardFrame.cgRectValue.height
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

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(message.isUser ? Color.green : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(20)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
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

