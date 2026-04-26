//
//  ResonanceAudioManager.swift
//  FlashMemory
//
//  Audio feedback manager
//

import AVFoundation
import UIKit

class ResonanceAudioManager {

    static let shared = ResonanceAudioManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isMuted: Bool = false

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Sound Effects

    func playTapSound() {
        generateSystemSound(systemID: 1104)
    }

    func playSuccessSound() {
        generateSystemSound(systemID: 1054)
    }

    func playFailureSound() {
        generateSystemSound(systemID: 1053)
    }

    func playRevealSound() {
        generateSystemSound(systemID: 1105)
    }

    private func generateSystemSound(systemID: SystemSoundID) {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(systemID)
    }

    // MARK: - Haptic Feedback

    func triggerLightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func triggerMediumHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func triggerHeavyHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Settings

    func toggleMute() {
        isMuted.toggle()
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
    }

    func isSoundMuted() -> Bool {
        return isMuted
    }
}
