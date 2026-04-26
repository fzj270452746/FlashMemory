//
//  QuantumGameState.swift
//  FlashMemory
//
//  Game state machine
//

import Foundation

enum QuantumGameState {
    case dormant            // Waiting to start
    case revelation         // Showing pattern
    case memorization       // Player memorizing
    case reconstruction     // Player recreating pattern
    case validation         // Checking result
    case triumph            // Success state
    case termination        // Game over
}

class CascadeStateMachine {

    private(set) var currentPhase: QuantumGameState = .dormant
    var phaseTransitionHandler: ((QuantumGameState) -> Void)?

    func transitionTo(_ newPhase: QuantumGameState) {
        currentPhase = newPhase
        phaseTransitionHandler?(newPhase)
    }

    func canTransitionTo(_ targetPhase: QuantumGameState) -> Bool {
        switch (currentPhase, targetPhase) {
        case (.dormant, .revelation),
             (.revelation, .memorization),
             (.memorization, .reconstruction),
             (.reconstruction, .validation),
             (.validation, .triumph),
             (.validation, .termination),
             (.triumph, .revelation),
             (.termination, .dormant):
            return true
        default:
            return false
        }
    }
}
