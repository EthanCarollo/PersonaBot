//
//  MyBotsView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//

import SwiftUI

struct MyBotsView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(0..<5) { index in
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundColor(.green)
                        Text("Bot \(index + 1)")
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Mes Bots", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fermer") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .accentColor(.green)
    }
}

struct MyBotsView_Previews: PreviewProvider {
    static var previews: some View {
        MyBotsView()
    }
}

