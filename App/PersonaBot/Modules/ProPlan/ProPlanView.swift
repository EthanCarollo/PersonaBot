//
//  ProPlanView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI

struct ProPlanView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Background waves
            ForEach(0..<15) { i in
                OrganicWave(waveOffset: Double(i) * 20)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    .rotationEffect(Angle(degrees: 20))
            }
            
            VStack(spacing: 30) {
                // Header
                Text("Pro Plan")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                // Subscription options
                VStack(spacing: 20) {
                    SubscriptionOption(
                        title: "Mensuel",
                        price: "6€",
                        period: "par mois",
                        action: { print("Monthly subscription selected") }
                    )
                    
                    SubscriptionOption(
                        title: "Annuel",
                        price: "54€",
                        period: "par an",
                        action: { print("Annual subscription selected") }
                    )
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

struct SubscriptionOption: View {
    let title: String
    let price: String
    let period: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(price)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.neonGreen)
                    
                    Text(period)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct ProPlanView_Previews: PreviewProvider {
    static var previews: some View {
        ProPlanView()
    }
}

