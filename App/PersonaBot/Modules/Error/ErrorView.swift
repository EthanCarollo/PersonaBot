//
//  ErrorView.swift
//  PersonaBot
//
//  Created by eth on 11/12/2024.
//
import SwiftUI

struct ErrorView: View {
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
                
                // Server illustration
                HStack(spacing: 20) {
                    VStack(spacing: 15) {
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 120, height: 30)
                                .overlay(
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .padding(.leading, 10)
                                        Spacer()
                                    }
                                )
                        }
                    }
                    
                    Image(systemName: "server.rack")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                }
                .padding(.bottom, 60)
                
                // Text content
                VStack(spacing: 16) {
                    Text("Un instant !")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Notre backend est en maintenance")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Nous nous excusons pour la gêne occasionnée.\nNous serons bientôt de retour.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                
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

#Preview {
    ErrorView()
}
