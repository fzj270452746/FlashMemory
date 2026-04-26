//
//  MatrixGridModel.swift
//  FlashMemory
//
//  Grid data model and pattern generation
//

import Foundation

struct CellularCoordinate: Hashable {
    let row: Int
    let column: Int
}

class MatrixGridModel {

    let dimensionality: Int
    private(set) var illuminatedCells: Set<CellularCoordinate> = []
    private(set) var memoryPatternColors: [CellularCoordinate: NexusConfiguration.MemoryColorTarget] = [:]

    init(dimensionality: Int) {
        self.dimensionality = dimensionality
    }

    func synthesizeRandomPattern(illuminationCount: Int) {
        synthesizeRandomPattern(
            illuminationCount: illuminationCount,
            activeColors: [.blue],
            targetColors: [.blue]
        )
    }

    func synthesizeRandomPattern(
        illuminationCount: Int,
        activeColors: [NexusConfiguration.MemoryColorTarget],
        targetColors: [NexusConfiguration.MemoryColorTarget]
    ) {
        illuminatedCells.removeAll()
        memoryPatternColors.removeAll()

        var availablePositions: [CellularCoordinate] = []
        for row in 0..<dimensionality {
            for col in 0..<dimensionality {
                availablePositions.append(CellularCoordinate(row: row, column: col))
            }
        }

        availablePositions.shuffle()
        let actualCount = min(illuminationCount, availablePositions.count)

        let palette = activeColors.isEmpty ? [.blue] : activeColors
        let mustIncludeTargets = targetColors.isEmpty ? [.blue] : targetColors

        for index in 0..<min(actualCount, mustIncludeTargets.count) {
            let coordinate = availablePositions[index]
            illuminatedCells.insert(coordinate)
            memoryPatternColors[coordinate] = mustIncludeTargets[index]
        }

        if actualCount > mustIncludeTargets.count {
            for i in mustIncludeTargets.count..<actualCount {
                let coordinate = availablePositions[i]
                illuminatedCells.insert(coordinate)
                let colorIndex = Int.random(in: 0..<palette.count)
                memoryPatternColors[coordinate] = palette[colorIndex]
            }
        }
    }

    func toggleCellIllumination(at coordinate: CellularCoordinate) {
        if illuminatedCells.contains(coordinate) {
            illuminatedCells.remove(coordinate)
        } else {
            illuminatedCells.insert(coordinate)
        }
    }

    func isCellIlluminated(at coordinate: CellularCoordinate) -> Bool {
        return illuminatedCells.contains(coordinate)
    }

    func validateAgainst(_ targetPattern: Set<CellularCoordinate>) -> Bool {
        return illuminatedCells == targetPattern
    }

    func clearAllIllumination() {
        illuminatedCells.removeAll()
    }

    func copyPattern() -> Set<CellularCoordinate> {
        return illuminatedCells
    }

    func copyColorPattern() -> [CellularCoordinate: NexusConfiguration.MemoryColorTarget] {
        return memoryPatternColors
    }
}
