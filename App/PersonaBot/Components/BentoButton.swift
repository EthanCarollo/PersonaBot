//
//  BentoButton.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct BentoButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Button(action: action) {
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
