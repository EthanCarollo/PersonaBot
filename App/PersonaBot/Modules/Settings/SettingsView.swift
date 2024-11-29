//
//  SettingsView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Préférences")) {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    Toggle("Mode sombre", isOn: $darkModeEnabled)
                }

                Section(header: Text("Compte")) {
                    Button("Changer le mot de passe") {
                        // Action to change password
                    }
                    Button("Déconnexion") {
                        // Action to log out
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Paramètres", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fermer") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .accentColor(.green)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

