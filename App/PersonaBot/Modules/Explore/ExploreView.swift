//
//  ExploreView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import Combine
import SwiftUI
import SwiftKeychainWrapper

struct ExploreView: View {
    @ObservedObject var authViewModel = AuthViewModel.shared
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showAuthAlert = false
    
    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Explore")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for a bot...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tint(.neonGreen)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredBots) { bot in
                                    BotCard(bot: bot, iconAction: "bookmark", isAuthenticated: viewModel.isAuthenticated, onAction: {
                                        viewModel.saveBot(bot: bot)
                                    })
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 72)
                        }
                    }
                }
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 35) {
                    // Main content
                    VStack(spacing: 25) {
                        Image(systemName: "person.fill")  // Replace with your bot image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            Text("Authentication Required")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Sign in to access all features")
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.top, 96)
                    Spacer()
                }
            }
            Spacer()
        }
        .onAppear(perform: {
            Task {
                await BotsViewModel.shared.fetchBots()
            }
        })
        
        if showAuthAlert {
            CustomAlert(isPresented: $showAuthAlert, message: "This feature is reserved for logged-in members")
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            showAuthAlert = false
                        }
                    }
                }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}

