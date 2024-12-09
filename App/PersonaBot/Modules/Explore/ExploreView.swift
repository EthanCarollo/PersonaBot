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
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showAuthAlert = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Explorer")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Rechercher un bot...", text: $viewModel.searchText)
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
                                    
                                    do {
                                        viewModel.saveBot(bot: bot)
                                    } catch {
                                        print(error)
                                    }
                                    
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 72)
                    }
                }
                
                
                
                Spacer()
            }.onAppear(perform: {
                Task {
                    await BotsViewModel.shared.fetchBots()
                }
            })
            
            if showAuthAlert {
                CustomAlert(isPresented: $showAuthAlert, message: "Fonctionnalité réservée aux membres connectés")
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
}
