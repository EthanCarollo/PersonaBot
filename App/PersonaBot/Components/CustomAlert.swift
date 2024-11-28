//
//  CustomAlert.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI

struct CustomAlert: View {
    @Binding var isPresented: Bool
    let message: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
            }
            .frame(width: geometry.size.width)
            .position(x: geometry.size.width / 2, y: geometry.safeAreaInsets.top + 40)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: isPresented)
        .zIndex(1)
    }
}


