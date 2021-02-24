//
//  Card.swift
//  Flashzilla
//
//  Created by Manuel Teixeira on 22/02/2021.
//

import Foundation

struct Card: Codable {
    let prompt: String
    var answer: String

    static var example: Card {
        Card(prompt: "Who played the 13th Doctor in Doctor who?", answer: "Jodie Whittaker")
    }
}
