//
//  Routine.swift
//  Nunchuck Routine Tracker
//
//  Created by Max Rivera on 1/11/26.
//

import Foundation

struct Routine: Identifiable, Codable {
    let id: UUID
    var name: String
    var discipline: String
    var attempts: [Attempt]
    
    init(id: UUID = UUID(), name: String, discipline: String = "Nunchucks", attempts: [Attempt] = []) {
        self.id = id
        self.name = name
        self.discipline = discipline
        self.attempts = attempts
    }
    
    mutating func addAttempt(_ attempt: Attempt) {
        attempts.append(attempt)
    }
}

struct Attempt: Identifiable, Codable {
    let id: UUID
    let date: Date
    let isSuccess: Bool
    
    init(id: UUID = UUID(), date: Date = Date(), isSuccess: Bool) {
        self.id = id
        self.date = date
        self.isSuccess = isSuccess
    }
}
