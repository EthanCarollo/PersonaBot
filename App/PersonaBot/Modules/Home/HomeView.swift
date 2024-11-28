//
//  HomeView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Background waves
            ForEach(0..<15) { i in
                OrganicWave(waveOffset: Double(i) * 20)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    .rotationEffect(Angle(degrees: 20))
            }
            
            VStack(spacing: 30) {
                // Header with Pro Plan button
                HStack {
                    Spacer()
                    Button(action: {
                        // Action for Pro Plan
                    }) {
                        Text("Pro Plan")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.neonGreen)
                            .cornerRadius(15)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                // Logo and title section
                VStack(spacing: 20) {
                    Text("Persona Bot")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.neonGreen)
                    
                    Image("Bot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color.neonGreen)
                        .shadow(color: Color.neonGreen.opacity(0.5), radius: 20)
                }
                
                // Welcome text
                VStack(spacing: 16) {
                    Text("Ton assistant IA,")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("au quotidien.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Bento grid
                VStack(spacing: 12) {
                    // First row
                    HStack(spacing: 12) {
                        // Chatter button (wider)
                        BentoButton(
                            title: "Chatter",
                            icon: "message",
                            destination: AnyView(ChatView()),
                            width: UIScreen.main.bounds.width * 0.6,
                            height: 80
                        )
                        
                        // Explorer button
                        BentoButton(
                            title: "Explorer",
                            icon: "magnifyingglass",
                            destination: AnyView(ExploreView()),
                            width: UIScreen.main.bounds.width * 0.3,
                            height: 80
                        )
                    }
                    
                    // Second row
                    HStack(spacing: 12) {
                        // Créer button
                        BentoButton(
                            title: "Créer",
                            icon: "plus.circle",
                            destination: AnyView(CreateBotView()),
                            width: UIScreen.main.bounds.width * 0.3,
                            height: 80
                        )
                        
                        // Mes Bots button (wider)
                        BentoButton(
                            title: "Mes Bots",
                            icon: "person.2",
                            destination: AnyView(MyBotsView()),
                            width: UIScreen.main.bounds.width * 0.6,
                            height: 80
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
}

struct BentoButton<Destination: View>: View {
    let title: String
    let icon: String
    let destination: Destination
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color.neonGreen)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white)
            }
            .frame(width: width, height: height)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct ExploreView: View {
    var body: some View {
        Text("Explore Chatbots")
    }
}

struct CreateBotView: View {
    var body: some View {
        Text("Create a Chatbot")
    }
}

struct MyBotsView: View {
    var body: some View {
        Text("My Chatbots")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

