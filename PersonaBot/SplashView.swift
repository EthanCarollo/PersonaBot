//
//  SplashView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct SplashScreen: View {
    @State private var glowOpacity = 0.0
    @State private var waveScale = 0.5
    @State private var waveRotation: Double = 0
    @State private var waveOffset: CGSize = .zero
    @State private var showFinalScreen = false
    @State private var botOffset: CGSize = .zero
    @State private var botScale: CGFloat = 1.0
    @State private var navigateToAuth = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Organic circular waves
                ForEach(0..<15) { i in
                    OrganicWave(waveOffset: Double(i) * 20)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        .scaleEffect(waveScale + Double(i) * 0.1)
                }
                .opacity(glowOpacity)
                .rotationEffect(Angle(degrees: waveRotation))
                .offset(x: 50 + waveOffset.width, y: 100 + waveOffset.height)
                
                VStack(spacing: 30) {
                    if showFinalScreen {
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
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    Spacer()
                    
                    // Bot image
                    Image("Bot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .scaleEffect(botScale)
                        .shadow(color: Color.green.opacity(0.5), radius: 20)
                        .offset(botOffset)
                    
                    Spacer()
                    
                    if showFinalScreen {
                        // Bottom text
                        VStack(spacing: 8) {
                            Text("Ton assistant IA,")
                                .font(.system(size: 28, weight: .bold))
                            Text("au quotidien.")
                                .font(.system(size: 28, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        
                        // Start button
                        NavigationLink(destination: ContentView(), isActive: $navigateToAuth) {
                            Button(action: {
                                navigateToAuth = true
                            }) {
                                Text("Commencer")
                                    .font(.system(size: 17, weight: .semibold))
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
                        .padding(.bottom, 40)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .opacity(glowOpacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0)) {
                    glowOpacity = 1.0
                    waveScale = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                        botOffset = CGSize(width: 0, height: -100)
                        botScale = 1.2
                        waveRotation = 20
                        waveOffset = CGSize(width: 0, height: -150)
                    }
                    
                    withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                        showFinalScreen = true
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct OrganicWave: Shape {
    var waveOffset: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX - 100, y: rect.midY - 50)
        
        path.move(to: CGPoint(x: center.x + 150, y: center.y))
        
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - 100 + CGFloat(waveOffset)),
            control1: CGPoint(x: center.x + 120, y: center.y - 50),
            control2: CGPoint(x: center.x + 60, y: center.y - 100 + CGFloat(waveOffset))
        )
        
        path.addCurve(
            to: CGPoint(x: center.x - 150, y: center.y + CGFloat(waveOffset/2)),
            control1: CGPoint(x: center.x - 60, y: center.y - 100 + CGFloat(waveOffset)),
            control2: CGPoint(x: center.x - 120, y: center.y - 50 + CGFloat(waveOffset/2))
        )
        
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y + 100),
            control1: CGPoint(x: center.x - 120, y: center.y + 50),
            control2: CGPoint(x: center.x - 60, y: center.y + 100)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x + 150, y: center.y),
            control1: CGPoint(x: center.x + 60, y: center.y + 100),
            control2: CGPoint(x: center.x + 120, y: center.y + 50)
        )
        
        return path
    }
}
