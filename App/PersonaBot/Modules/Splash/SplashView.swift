//
//  SplashView.swift
//  PersonaBot
//
//  Created by eth on 12/12/2024.
//
import SwiftUI

struct SplashView: View {
    @State private var glowOpacity = 0.0
    @State private var waveScale = 0.5
    @State private var waveRotation: Double = 0
    @State private var waveOffset: CGSize = .zero
    @State private var showContent = false
    @State private var botOpacity: Double = 0.0
    @State private var botScale: CGFloat = 0.9
    @State private var navigateToAuth = false
    @State private var textOpacity = 0.0
    @State private var buttonOpacity = 0.0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Organic circular waves
                ForEach(0..<15) { i in
                    OrganicWave(waveOffset: Double(i) * 20)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        .scaleEffect(waveScale + Double(i) * 0.05)
                }
                .opacity(glowOpacity)
                .rotationEffect(Angle(degrees: waveRotation))
                .offset(x: 50 + waveOffset.width, y: 100 + waveOffset.height)
                
                VStack(spacing: 30) {
                    // Top text
                    Text("PersonaBot")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.green)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.2))
                        )
                        .opacity(textOpacity)
                        .offset(y: showContent ? 0 : -20)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Bot image
                    Image("Bot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .scaleEffect(botScale)
                        .opacity(botOpacity)
                        .shadow(color: Color.green.opacity(0.5), radius: 20)
                    
                    Spacer()
                    
                    // Bottom text
                    VStack(spacing: 8) {
                        Text("Create Your Own AI Assistant,")
                            .font(.system(size: 22, weight: .bold))
                        Text("tailored just for you.")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.top, -4)
                    }
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Start button
                    NavigationLink(destination: ContentView(), isActive: $navigateToAuth) {
                        Button(action: {
                            navigateToAuth = true
                        }) {
                            Text("Start")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.white)
                                )
                                .padding(.horizontal, 20)
                        }
                    }
                    .opacity(buttonOpacity)
                    .offset(y: showContent ? 0 : 40)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                animateEntrance()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func animateEntrance() {
        withAnimation(.easeOut(duration: 1.5)) {
            glowOpacity = 1.0
            waveScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
            botOpacity = 1.0
            botScale = 1.0
            waveRotation = 10
            waveOffset = CGSize(width: 0, height: -75)
            showContent = true
        }
        
        withAnimation(.easeInOut(duration: 1.0).delay(1.5)) {
            textOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.8).delay(2.0)) {
            buttonOpacity = 1.0
        }
        
        // Fetch bots
        Task {
            await BotsViewModel.shared.fetchBots()
        }
    }
}

#Preview {
    SplashView()
}
