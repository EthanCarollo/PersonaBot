//
//  UpdateView.swift
//  PersonaBot
//
//  Created by eth on 11/12/2024.
//


import SwiftUI

struct UpdateView: View {
    @State private var starOpacity = 0.0
    @State private var contentOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Stars background effect
            ForEach(0..<30) { index in
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(starOpacity)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Update illustration
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "arrow.clockwise.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                }
                .padding(.bottom, 60)
                
                // Text content
                VStack(spacing: 16) {
                    Text("Mise à jour disponible")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Une nouvelle version de PersonaBot est disponible")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("Veuillez mettre à jour l'application\npour profiter des dernières fonctionnalités.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                
                // Update button
                Button(action: {
                    // Add action to open App Store or trigger update
                }) {
                    Text("Mettre à jour maintenant")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                }
                .padding(.top, 30)
                
                Spacer()
                
                // Logo
                Text("PersonaBot")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
                    .padding(.bottom, 40)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                starOpacity = 0.5
            }
            
            withAnimation(.easeIn(duration: 1.5)) {
                contentOpacity = 1.0
            }
        }
    }
}
