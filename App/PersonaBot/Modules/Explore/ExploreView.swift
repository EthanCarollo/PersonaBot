//
//  ExploreView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct Bot: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    var isSaved: Bool
}

class ExploreViewModel: ObservableObject {
    @Published var bots: [Bot]
    @Published var searchText: String = ""
    
    init() {
        self.bots = [
            Bot(name: "Ugo sans H", description: "Assistant développeur SwiftUI sarcastique et passionné", icon: "terminal", isSaved: false),
            Bot(name: "Chef Michel", description: "Expert culinaire français, spécialiste de la cuisine traditionnelle", icon: "fork.knife", isSaved: false),
            Bot(name: "Prof. Einstein", description: "Tuteur de physique et mathématiques", icon: "function", isSaved: false),
            Bot(name: "Dr. Watson", description: "Assistant médical pour des conseils de santé généraux", icon: "cross.case", isSaved: false),
            Bot(name: "Eco Guide", description: "Conseiller en développement durable et écologie", icon: "leaf", isSaved: false)
        ]
    }
    
    func toggleSave(for bot: Bot) {
        if let index = bots.firstIndex(where: { $0.id == bot.id }) {
            bots[index].isSaved.toggle()
        }
    }
    
    var filteredBots: [Bot] {
        if searchText.isEmpty {
            return bots
        }
        return bots.filter { $0.name.localizedCaseInsensitiveContains(searchText) ||
                             $0.description.localizedCaseInsensitiveContains(searchText) }
    }
}

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    
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
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredBots) { bot in
                            BotCard(bot: bot) {
                                viewModel.toggleSave(for: bot)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 72) // Ajout de padding en bas
                }
                
                Spacer()
            }
        }
    }
}

struct BotCard: View {
    let bot: Bot
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: bot.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.neonGreen)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(bot.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: onSave) {
                    Image(systemName: bot.isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(bot.isSaved ? .neonGreen : .gray)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}



