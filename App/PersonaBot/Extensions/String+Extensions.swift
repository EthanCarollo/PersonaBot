//
//  String+Extensions.swift
//  PersonaBot
//
//  Created by eth on 30/11/2024.
//

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
