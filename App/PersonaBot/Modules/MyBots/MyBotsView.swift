//
//  MyBotsView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import SwiftUI

struct MyBotsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var bots: [Bot] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Rechercher un bot...", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                            .scaleEffect(2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Bots list
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredBots) { bot in
                                    BotCard(bot: bot, iconAction: "person.slash", isAuthenticated: true, onAction: {
                                        Task {
                                            await SupabaseService.shared.deleteUserSavedBot(botId: bot.id)
                                            DispatchQueue.main.async {
                                                setBots()
                                            }
                                        }
                                     
                                    })
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitle("Mes Bots", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fermer") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .accentColor(.neonGreen)
        .onAppear {
            setBots()
        }
    }
    
    private var filteredBots: [Bot] {
        if searchText.isEmpty {
            return bots
        } else {
            return bots.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func setBots() {
        isLoading = true
        Task {
            let botsRequest = await SupabaseService.shared.getUserSavedBots()
            if let fetchedBots = botsRequest {
                await MainActor.run {
                    self.bots = fetchedBots
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                    // Handle error case here, e.g., show an alert
                }
            }
        }
    }
}

struct MyBotsView_Previews: PreviewProvider {
    static var previews: some View {
        MyBotsView()
    }
}
