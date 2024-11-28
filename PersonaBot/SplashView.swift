//
//  SplashView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI

struct SplashScreen: View {
    @State private var glowOpacity = 0.0
    @State private var rippleScale = 0.5
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Deformed ripple effect
            ForEach(0..<12) { i in
                DeformedCircle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                    .scaleEffect(rippleScale + Double(i) * 0.1)
            }
            .opacity(glowOpacity)
            
            // Bot image
            Image("Bot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .shadow(color: Color.green.opacity(0.5), radius: 20)
                .opacity(glowOpacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                glowOpacity = 1.0
                rippleScale = 1.0
            }
        }
    }
}

struct DeformedCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: CGPoint(x: center.x + radius, y: center.y))
        
        for angle in stride(from: 0, to: 360, by: 10) {
            let angleInRadians = Angle(degrees: Double(angle)).radians
            let distortionFactor = CGFloat.random(in: 0.9...1.1)
            let x = center.x + cos(angleInRadians) * radius * distortionFactor
            let y = center.y + sin(angleInRadians) * radius * distortionFactor
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.closeSubpath()
        return path
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
