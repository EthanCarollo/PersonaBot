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
                // Logo and title section
                VStack(spacing: 20) {
                    Text("Iakadir")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.neonGreen)
                    
                    Image("Bot") // Make sure to add your bot image to assets
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color.neonGreen)
                        .shadow(color: Color.neonGreen.opacity(0.5), radius: 20)
                }
                .padding(.top, 60)
                
                Spacer()
                
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
                
                // Start button
                NavigationLink(destination: ChatView()) {
                    Text("Commencer")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .padding(.bottom, 100) // Increased to account for NavBar
            }
            .padding()
        }
    }
}



