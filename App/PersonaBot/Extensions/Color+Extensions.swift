//
//  Color+Extensions.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

extension Color {
    static let neonGreen = Color(hue: 0.333, saturation: 1.0, brightness: 1.0)
    static let neonPink = Color(hue: 0.917, saturation: 1.0, brightness: 1.0)
    static let neonBlue = Color(hue: 0.583, saturation: 1.0, brightness: 1.0)
    static let neonYellow = Color(hue: 0.167, saturation: 1.0, brightness: 1.0)
    
    // Fonction utilitaire pour créer des couleurs néon
    static func neon(_ hue: Double) -> Color {
        return Color(hue: hue, saturation: 1.0, brightness: 1.0)
    }
}

// Prévisualisation pour tester les couleurs
struct ColorExtension_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Rectangle().fill(Color.neonGreen).frame(height: 50)
            Rectangle().fill(Color.neonPink).frame(height: 50)
            Rectangle().fill(Color.neonBlue).frame(height: 50)
            Rectangle().fill(Color.neonYellow).frame(height: 50)
            Rectangle().fill(Color.neon(0.75)).frame(height: 50) // Exemple de couleur néon personnalisée
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}


