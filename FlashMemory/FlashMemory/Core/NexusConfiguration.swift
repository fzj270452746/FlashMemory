//
//  NexusConfiguration.swift
//  FlashMemory
//
//  Central configuration for game parameters
//

import UIKit

struct NexusConfiguration {

    enum MemoryColorTarget: String, CaseIterable {
        case blue
        case red
        case green

        var displayName: String {
            switch self {
            case .blue: return "Blue"
            case .red: return "Red"
            case .green: return "Green"
            }
        }

        var color: UIColor {
            switch self {
            case .blue:
                return UIColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0)
            case .red:
                return UIColor(red: 1.0, green: 0.38, blue: 0.42, alpha: 1.0)
            case .green:
                return UIColor(red: 0.35, green: 0.95, blue: 0.58, alpha: 1.0)
            }
        }
    }

    // Grid dimensions based on level
    static func gridDimensionality(forStage stage: Int) -> Int {
        switch stage {
        case 1...5: return 3
        case 6...10: return 4
        case 11...20: return 5
        default: return 6
        }
    }

    // Display duration for pattern
    static func revelationDuration(forStage stage: Int) -> TimeInterval {
        switch stage {
        case 1...5: return 2.0
        case 6...10: return 1.5
        default: return 1.0
        }
    }

    // Number of illuminated cells
    static func illuminationQuantity(forStage stage: Int) -> Int {
        switch stage {
        case 1...5: return 3
        case 6...15: return 5
        default: return 8
        }
    }

    static func activeMemoryColors(forStage stage: Int) -> [MemoryColorTarget] {
        switch stage {
        case 1...4:
            return [.blue]
        case 5...12:
            return [.blue, .red]
        default:
            return [.blue, .red, .green]
        }
    }

    static func targetMemoryColors(forStage stage: Int, illuminationCount: Int) -> [MemoryColorTarget] {
        let activeColors = activeMemoryColors(forStage: stage)
        let maxSelectableCount = max(1, min(illuminationCount, activeColors.count))

        switch stage {
        case 1...4:
            return [activeColors[0]]
        case 5...12:
            let targetCount = min(Bool.random() ? 1 : 2, maxSelectableCount)
            return Array(activeColors.shuffled().prefix(targetCount))
        default:
            let roll = Int.random(in: 0..<100)

            if roll < 35 {
                return [activeColors.randomElement() ?? .blue]
            }

            if roll < 70 {
                let targetCount = min(2, maxSelectableCount)
                return Array(activeColors.shuffled().prefix(targetCount))
            }

            return Array(activeColors.shuffled().prefix(maxSelectableCount))
        }
    }

    // Color palette for UI
    struct ChromaticPalette {
        static let primaryGradientStart = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        static let primaryGradientEnd = UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 1.0)

        static let secondaryGradientStart = UIColor(red: 0.2, green: 0.8, blue: 0.8, alpha: 1.0)
        static let secondaryGradientEnd = UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 1.0)

        static let accentGradientStart = UIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0)
        static let accentGradientEnd = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)

        static let cellIlluminated = UIColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0)
        static let cellDormant = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        static let cellBorder = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 0.5)

        static let backgroundDark = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        static let textPrimary = UIColor.white
        static let textSecondary = UIColor(white: 0.8, alpha: 1.0)
    }

    // Animation timings
    struct TemporalRhythm {
        static let cellFlashDuration: TimeInterval = 0.3
        static let successCelebration: TimeInterval = 1.0
        static let transitionFade: TimeInterval = 0.5
        static let pulseAnimation: TimeInterval = 0.8
    }

    // Layout constants
    struct SpatialMetrics {
        static let cellSpacing: CGFloat = 8.0
        static let cellCornerRadius: CGFloat = 12.0
        static let buttonHeight: CGFloat = 56.0
        static let buttonCornerRadius: CGFloat = 28.0
        static let modalPadding: CGFloat = 24.0
    }
}
