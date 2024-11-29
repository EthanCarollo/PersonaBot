//
//  ContentView.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var botsViewModel = BotsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                
                ExploreView()
                    .tag(1)
                
                ChatView()
                    .tag(2)
                
                AccountView()
                    .environmentObject(authViewModel)
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.bottom)
            
            NavBar(selectedTab: $selectedTab)
                .padding(.bottom, safeAreaBottomPadding())
        }
        .edgesIgnoringSafeArea(.bottom)
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


