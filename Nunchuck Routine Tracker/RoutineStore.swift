//
//  RoutineStore.swift
//  Nunchuck Routine Tracker
//
//  Created by Max Rivera on 1/11/26.
//

import Foundation

@Observable
class RoutineStore {
    var routines: [Routine] = [] {
        didSet {
            save()
        }
    }
    
    private let saveKey = "SavedRoutines"
    
    init() {
        load()
    }
    
    func addRoutine(name: String, discipline: String) {
        let newRoutine = Routine(name: name, discipline: discipline)
        routines.append(newRoutine)
    }
    
    func addAttempt(to routine: Routine, isSuccess: Bool) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            let attempt = Attempt(isSuccess: isSuccess)
            routines[index].addAttempt(attempt)
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Routine].self, from: data) {
            routines = decoded
        }
    }
}
