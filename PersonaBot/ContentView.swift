//
//  ContentView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var showAuthView = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                ChatView()
                    .tag(1)
                
                AccountView(isAuthenticated: $isAuthenticated, showAuthView: $showAuthView)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.bottom)
            
            NavBar(selectedTab: $selectedTab)
                .padding(.bottom, safeAreaBottomPadding())
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showAuthView) {
            AuthView(isAuthenticated: $isAuthenticated)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private func safeAreaBottomPadding() -> CGFloat {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first { $0 is UIWindowScene } as? UIWindowScene
            let keyWindow = windowScene?.windows.first { $0.isKeyWindow }
            return keyWindow?.safeAreaInsets.bottom ?? 0
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


