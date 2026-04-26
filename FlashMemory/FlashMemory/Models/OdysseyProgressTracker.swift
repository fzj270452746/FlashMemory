//
//  OdysseyProgressTracker.swift
//  FlashMemory
//
//  Level progression and scoring
//

import Foundation

class OdysseyProgressTracker {

    private(set) var currentStage: Int = 1
    private(set) var accumulatedScore: Int = 0
    private(set) var consecutiveTriumphs: Int = 0

    func advanceToNextStage() {
        currentStage += 1
        consecutiveTriumphs += 1
    }

    func registerTriumph(timeBonus: Int = 0) {
        let basePoints = currentStage * 100
        accumulatedScore += basePoints + timeBonus
    }

    func resetProgression() {
        currentStage = 1
        accumulatedScore = 0
        consecutiveTriumphs = 0
    }

    func recordTermination() {
        consecutiveTriumphs = 0
    }
}

class ChronosTimerController {

    private var remainingDuration: TimeInterval
    private var timerUpdateCallback: ((TimeInterval) -> Void)?
    private var completionCallback: (() -> Void)?
    private var timer: Timer?

    init(totalDuration: TimeInterval) {
        self.remainingDuration = totalDuration
    }

    func initiateCountdown(updateHandler: @escaping (TimeInterval) -> Void, completion: @escaping () -> Void) {
        self.timerUpdateCallback = updateHandler
        self.completionCallback = completion

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingDuration -= 0.1

            if self.remainingDuration <= 0 {
                self.remainingDuration = 0
                self.terminateCountdown()
                self.completionCallback?()
            } else {
                self.timerUpdateCallback?(self.remainingDuration)
            }
        }
    }

    func terminateCountdown() {
        timer?.invalidate()
        timer = nil
    }

    func getRemainingTime() -> TimeInterval {
        return remainingDuration
    }
}
