//
//  BotCreable.swift
//  PersonaBot
//
//  Created by eth on 29/11/2024.
//
import Foundation
import SwiftUI


public struct BotCreable: Identifiable {
    public let id = UUID()
    var name: String
    var description: String
    var publicId: String
    var knowledge: [String]
    var icon: String
}
