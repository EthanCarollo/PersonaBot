//
//  BackendService.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import Foundation

public class BackendService {
    static let shared = BackendService()
    private var backendUrl = Config.backendURL
    
    public func isAlive() async -> Bool {
        do {
            struct AliveResponse: Decodable {
                let isAlive: Bool
            }
            let endpoint = "/health"
            guard let url = URL(string: self.backendUrl + endpoint) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(AliveResponse.self, from: data)
            print(response.isAlive)
        
            return response.isAlive
        } catch {
            print("BACKEND IS UNAVAILABLE")
            return false
        }
    }
    
    public func isCompatible() async -> Bool {
        do {
            struct VersionResponse: Decodable {
                let version: String
            }
            
            let endpoint = "/version"
            guard let url = URL(string: self.backendUrl + endpoint) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(VersionResponse.self, from: data)
            print(response.version)
            print(Config.appVersion)
            if response.version == Config.appVersion {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    public func sendMessageToBackend(message: String, botPublicId: String) async throws -> String {
        // Déterminer l'URL en fonction de l'ID du bot, si c'est le classic, alors on va just chatter normalement
        let endpoint = botPublicId == "classic" ? "/chat" : "/chat_with_bot"
        guard let url = URL(string: self.backendUrl + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var token = ""
        do {
            token = try await SupabaseService.shared.client.auth.session.accessToken
        } catch {
            print("Got an error on get token")
        }
        let body = ["text": message, "bot_public_id": botPublicId, "token": token ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
        return response.response
    }
    
    public func saveBot(botId: UUID) async throws -> String {
        let endpoint = "/bot/add"
        guard let url = URL(string: self.backendUrl + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var token = ""
        do {
            token = try await SupabaseService.shared.client.auth.session.accessToken
        } catch {
            print("Got an error on get token")
        }
        let body = ["bot_id": botId.uuidString, "token": token]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
        return response.response
    }
    
    public func createBot(bot: BotCreable) async throws -> Void {
        let endpoint = "/bot/create"
        guard let url = URL(string: self.backendUrl + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var token = ""
        do {
            token = try await SupabaseService.shared.client.auth.session.accessToken
        } catch {
            print("Got an error on get token")
        }
        let body = BotRequest(botPublicId: bot.publicId, token: token, botName: bot.name, description: bot.description, knowledges: bot.knowledge, icon: bot.icon, instruction: bot.instruction)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        _ = try JSONDecoder().decode(BackendResponse.self, from: data)
        return
    }
}

struct BotRequest: Encodable {
    let botPublicId: String
    let token: String
    let botName: String
    let description: String
    let knowledges: [String]
    let icon: String
    let instruction: String
}
