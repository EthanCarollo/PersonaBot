//
//  Navbar.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

// TODO : rename this file lol
import SwiftUI

struct NavBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TabBarButton(imageName: "house", title: "Accueil", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabBarButton(imageName: "magnifyingglass", title: "Explorer", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabBarButton(imageName: "message", title: "Chat", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                TabBarButton(imageName: "person", title: "Compte", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color.black.opacity(0.8))
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .background(Color.black.opacity(0.8))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color.neonGreen : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color.neonGreen : .gray)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear) // Ajout d'un fond transparent
    }
}

#if DEBUG
struct NavBar_Previews: PreviewProvider {
    @State static var selectedTab = 0
    
    static var previews: some View {
        NavBar(selectedTab: $selectedTab)
            .previewLayout(.sizeThatFits)
            .background(Color.black) // Pour voir la barre de navigation sur un fond noir
    }
}
#endif



