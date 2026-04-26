//
//  EchoGameMode.swift
//  FlashMemory
//
//  Game mode definitions
//

import Foundation

enum EchoGameMode {
    case odyssey        // Progressive levels
    case chronos        // Time-limited
    case zenith         // Extreme difficulty

    var displayTitle: String {
        switch self {
        case .odyssey: return "Odyssey Mode"
        case .chronos: return "Chronos Mode"
        case .zenith: return "Zenith Mode"
        }
    }

    var descriptionText: String {
        switch self {
        case .odyssey: return "Progressive levels"
        case .chronos: return "60s time challenge"
        case .zenith: return "Extreme difficulty"
        }
    }
}
