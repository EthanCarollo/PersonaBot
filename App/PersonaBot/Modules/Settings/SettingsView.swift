//
//  SettingsView.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Compte")) {
                    Button("Déconnexion") {
                        Task {
                            await SupabaseService.shared.logout()
                        }
                        authViewModel.isAuthenticated = false
                        presentationMode.wrappedValue.dismiss()
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

