//
//  HomeView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct HomeView: View {
    @Binding public var selectedTab: Int
    @State private var showProPlanView = false
    
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
                        showProPlanView = true
                    }) {
                        Text("Pro Plan")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.neonGreen)
                            .cornerRadius(15)
                            .padding(.trailing, 8)
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
                
                VStack(spacing: 8) {
                    Text("Create Your Own AI Assistant,")
                        .font(.system(size: 22, weight: .bold))
                    Text("tailored just for you.")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.top, -4)
                }
                
                Spacer()
                
                VStack {
                    // Chatter button (wider)
                    
                    HStack {
                        Button(action: {
                            selectedTab = 2
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "message")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.neonGreen)
                                Text("Chat")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.white)
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.6, height: 80)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        BentoButton(
                            title: "Explore",
                            icon: "magnifyingglass",
                            action: { selectedTab = 1 },
                            width: UIScreen.main.bounds.width * 0.3,
                            height: 80
                        )
                    }
                    HStack {
                        BentoButton(
                            title: "Create",
                            icon: "plus.circle",
                            action: { selectedTab = 3 },
                            width: UIScreen.main.bounds.width * 0.3,
                            height: 80
                        )
                        BentoButton(
                            title: "My Bots",
                            icon: "person.2",
                            action: { selectedTab = 3 },
                            width: UIScreen.main.bounds.width * 0.6,
                            height: 80
                        )
                    }
                }
                .padding()
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .sheet(isPresented: $showProPlanView) {
            ProPlanView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
    }
}

