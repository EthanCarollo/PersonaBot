//
//  PersonaBotApp.swift
//  PersonaBot
//
//  Created by eth on 28/11/2024.
//

import SwiftUI

@main
struct PersonaBotApp: App {
    @State private var backendIsAlive = true
    @State private var isChecking = true
    @State private var isCompatible = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isChecking {
                    ProgressView("Vérification du backend...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .foregroundColor(.green)
                } else if backendIsAlive == false {
                    ErrorView()
                } else if isCompatible == false {
                    UpdateView()
                } else {
                    SplashScreen()
                }
            }
            .onAppear(perform: checkAppStatus)
        }
    }
    
    private func checkAppStatus() {
        isChecking = true
        Task {
            do {
                let backendResult = try await withTimeout(seconds: 5) {
                    await BackendService.shared.isAlive()
                }
                backendIsAlive = backendResult
                print(backendIsAlive)
                let compatibilityResult = try await withTimeout(seconds: 3) {
                    await BackendService.shared.isCompatible()
                }
                isCompatible = compatibilityResult
                print(isCompatible)
            } catch is TimeoutError {
                isCompatible = false
                backendIsAlive = false
                print("Check timed out")
            } catch {
                isCompatible = false
                backendIsAlive = false
                print("Error checking app status: \(error.localizedDescription)")
            }
            isChecking = false
        }
    }

    private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private struct TimeoutError: Error {}}
