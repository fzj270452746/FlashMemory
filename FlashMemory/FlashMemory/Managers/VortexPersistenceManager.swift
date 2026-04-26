//
//  VortexPersistenceManager.swift
//  FlashMemory
//
//  Data persistence for scores and achievements
//

import Foundation

class VortexPersistenceManager {

    static let shared = VortexPersistenceManager()

    private let userDefaults = UserDefaults.standard

    private enum StorageKey: String {
        case highestStageOdyssey = "apex_stage_odyssey"
        case highestScoreOdyssey = "apex_score_odyssey"
        case highestScoreChronos = "apex_score_chronos"
        case highestStageZenith = "apex_stage_zenith"
        case totalGamesPlayed = "cumulative_sessions"
        case totalPatternsMemorized = "cumulative_patterns"
    }

    private init() {}

    // MARK: - Odyssey Mode

    func recordOdysseyProgress(stage: Int, score: Int) {
        let currentHighStage = retrieveHighestStage(mode: .odyssey)
        if stage > currentHighStage {
            userDefaults.set(stage, forKey: StorageKey.highestStageOdyssey.rawValue)
        }

        let currentHighScore = retrieveHighestScore(mode: .odyssey)
        if score > currentHighScore {
            userDefaults.set(score, forKey: StorageKey.highestScoreOdyssey.rawValue)
        }

        incrementTotalGames()
    }

    func retrieveHighestStage(mode: EchoGameMode) -> Int {
        switch mode {
        case .odyssey:
            return userDefaults.integer(forKey: StorageKey.highestStageOdyssey.rawValue)
        case .zenith:
            return userDefaults.integer(forKey: StorageKey.highestStageZenith.rawValue)
        default:
            return 0
        }
    }

    func retrieveHighestScore(mode: EchoGameMode) -> Int {
        switch mode {
        case .odyssey:
            return userDefaults.integer(forKey: StorageKey.highestScoreOdyssey.rawValue)
        case .chronos:
            return userDefaults.integer(forKey: StorageKey.highestScoreChronos.rawValue)
        default:
            return 0
        }
    }

    // MARK: - Chronos Mode

    func recordChronosScore(_ score: Int) {
        let currentHigh = retrieveHighestScore(mode: .chronos)
        if score > currentHigh {
            userDefaults.set(score, forKey: StorageKey.highestScoreChronos.rawValue)
        }

        incrementTotalGames()
    }

    // MARK: - Zenith Mode

    func recordZenithProgress(stage: Int) {
        let currentHigh = retrieveHighestStage(mode: .zenith)
        if stage > currentHigh {
            userDefaults.set(stage, forKey: StorageKey.highestStageZenith.rawValue)
        }

        incrementTotalGames()
    }

    // MARK: - Statistics

    private func incrementTotalGames() {
        let current = userDefaults.integer(forKey: StorageKey.totalGamesPlayed.rawValue)
        userDefaults.set(current + 1, forKey: StorageKey.totalGamesPlayed.rawValue)
    }

    func incrementPatternsMemorized() {
        let current = userDefaults.integer(forKey: StorageKey.totalPatternsMemorized.rawValue)
        userDefaults.set(current + 1, forKey: StorageKey.totalPatternsMemorized.rawValue)
    }

    func retrieveTotalGamesPlayed() -> Int {
        return userDefaults.integer(forKey: StorageKey.totalGamesPlayed.rawValue)
    }

    func retrieveTotalPatternsMemorized() -> Int {
        return userDefaults.integer(forKey: StorageKey.totalPatternsMemorized.rawValue)
    }

    // MARK: - Reset

    func obliterateAllData() {
        let allKeys: [StorageKey] = [
            .highestStageOdyssey,
            .highestScoreOdyssey,
            .highestScoreChronos,
            .highestStageZenith,
            .totalGamesPlayed,
            .totalPatternsMemorized
        ]

        for key in allKeys {
            userDefaults.removeObject(forKey: key.rawValue)
        }
    }
}
