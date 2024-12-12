//
//  MyBotsView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI

struct MyBotsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MyBotsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search a bot...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    GeometryReader { geometry in
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                                .scaleEffect(2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewModel.savedBots.filter({ $0.bot_public_id != "classic" }).isEmpty {
                            
                            VStack(spacing: 20) {
                                Image(systemName: "robot")
                                    .font(.system(size: 60))
                                    .foregroundColor(.neonGreen)
                                
                                Text("Oh, you don't have any Bots yet!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                Text("Go to 'Explore' to add some.")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.bottom, 50)
                            .frame(width: geometry.size.width)
                            .frame(minHeight: geometry.size.height)
                        } else {
                            // Bots list
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredBots) { bot in
                                        if bot.bot_public_id != "classic" {
                                            BotCard(bot: bot, iconAction: "person.slash", isAuthenticated: true, onAction: {
                                                Task {
                                                    await viewModel.deleteBot(botId: bot.id)
                                                }
                                            })
                                        }
                                        
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("My Bots", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fermer") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .accentColor(.neonGreen)
        .onAppear {
            Task {
                await viewModel.fetchBots()
            }
        }
    }
}


struct MyBotsView_Previews: PreviewProvider {
    static var previews: some View {
        MyBotsView()
    }
}

