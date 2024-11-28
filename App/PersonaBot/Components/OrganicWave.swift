//
//  OrganicWave.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

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
