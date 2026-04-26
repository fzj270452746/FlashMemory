//
//  HistoryArchive.swift
//  FlashMemory
//
//  History record management for different game modes
//

import Foundation

struct GameRecord: Codable {
    let mode: String
    let score: Int
    let stage: Int
    let timestamp: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: timestamp)
    }
}

class HistoryArchive {

    static let shared = HistoryArchive()

    private let storageKey = "gameHistoryRecords"
    private let maxRecordsPerMode = 10

    private init() {}

    // Save a new game record
    func saveRecord(mode: EchoGameMode, score: Int, stage: Int) {
        var records = loadAllRecords()

        let newRecord = GameRecord(
            mode: modeKey(mode),
            score: score,
            stage: stage,
            timestamp: Date()
        )

        records.append(newRecord)

        // Sort by score descending
        records.sort { $0.score > $1.score }

        // Keep only top records per mode
        var modeRecords: [String: [GameRecord]] = [:]
        for record in records {
            if modeRecords[record.mode] == nil {
                modeRecords[record.mode] = []
            }
            if modeRecords[record.mode]!.count < maxRecordsPerMode {
                modeRecords[record.mode]!.append(record)
            }
        }

        // Flatten back to array
        let filteredRecords = modeRecords.values.flatMap { $0 }

        saveRecords(filteredRecords)
    }

    // Load records for specific mode
    func loadRecords(for mode: EchoGameMode) -> [GameRecord] {
        let allRecords = loadAllRecords()
        let key = modeKey(mode)
        return allRecords.filter { $0.mode == key }
            .sorted { $0.score > $1.score }
    }

    // Load all records
    func loadAllRecords() -> [GameRecord] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let records = try? JSONDecoder().decode([GameRecord].self, from: data) else {
            return []
        }
        return records
    }

    // Get best score for mode
    func getBestScore(for mode: EchoGameMode) -> Int {
        let records = loadRecords(for: mode)
        return records.first?.score ?? 0
    }

    // Get highest stage for mode
    func getHighestStage(for mode: EchoGameMode) -> Int {
        let records = loadRecords(for: mode)
        return records.map { $0.stage }.max() ?? 0
    }

    // Clear all records
    func clearAllRecords() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // Clear records for specific mode
    func clearRecords(for mode: EchoGameMode) {
        var allRecords = loadAllRecords()
        let key = modeKey(mode)
        allRecords.removeAll { $0.mode == key }
        saveRecords(allRecords)
    }

    // MARK: - Private Helpers

    private func saveRecords(_ records: [GameRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func modeKey(_ mode: EchoGameMode) -> String {
        switch mode {
        case .odyssey: return "odyssey"
        case .chronos: return "chronos"
        case .zenith: return "zenith"
        }
    }
}
