//
//  BotCard.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//
import SwiftUI


struct BotCard: View {
    let bot: Bot
    let iconAction: String
    let isAuthenticated: Bool
    let onAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: bot.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.neonGreen)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bot.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(bot.description ?? "")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        
                }
                
                Spacer()
                
                Button(action: onAction) {
                    Image(systemName: iconAction)
                        .font(.system(size: 20))
                        .foregroundColor(.neonGreen)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
