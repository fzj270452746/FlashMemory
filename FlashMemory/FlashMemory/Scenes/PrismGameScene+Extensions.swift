//
//  PrismGameScene+Extensions.swift
//  FlashMemory
//
//  Game scene extensions for phase handling
//

import SpriteKit

extension PrismGameScene {

    private func colorForCell(at coordinate: CellularCoordinate) -> NexusConfiguration.MemoryColorTarget? {
        return targetPatternColors[coordinate]
    }

    private func currentObjectiveText() -> String {
        let colorNames = objectiveColors.map { $0.displayName }
        let targetText: String

        if colorNames.count == 1 {
            targetText = colorNames[0]
        } else if colorNames.count == 2 {
            targetText = colorNames.joined(separator: " + ")
        } else {
            targetText = colorNames.dropLast().joined(separator: ", ") + " + " + (colorNames.last ?? "")
        }

        return "Find all \(targetText) tiles"
    }

    private func presentObjectivePrompt() {
        objectiveLabel.text = currentObjectiveText()
        objectiveLabel.isHidden = false
        objectiveLabel.alpha = 0
        objectiveLabel.removeAllActions()

        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.18),
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeOut(withDuration: 0.22),
            SKAction.run { [weak self] in
                self?.objectiveLabel.isHidden = true
            }
        ])
        objectiveLabel.run(sequence)
    }

    private func updatePhaseHint(for phase: QuantumGameState) {
        switch phase {
        case .revelation:
            phaseHintLabel.text = "Memorize the colored tiles"
        case .memorization:
            phaseHintLabel.text = currentObjectiveText()
        case .reconstruction:
            phaseHintLabel.text = currentObjectiveText()
        case .validation:
            phaseHintLabel.text = "Checking your selection..."
        case .triumph:
            phaseHintLabel.text = "Great memory!"
        case .termination:
            phaseHintLabel.text = "Try again"
        case .dormant:
            phaseHintLabel.text = nil
        }
    }

    private func selectedObjectivePattern() -> Set<CellularCoordinate> {
        return Set(targetPattern.filter {
            guard let color = targetPatternColors[$0] else { return false }
            return objectiveColors.contains(color)
        })
    }

    private func applyAppearance(
        to node: SKShapeNode,
        colorTarget: NexusConfiguration.MemoryColorTarget?,
        isVisible: Bool,
        animated: Bool = true
    ) {
        if animated && isVisible {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
            node.run(SKAction.sequence([scaleUp, scaleDown]))
        }

        node.fillColor = isVisible ? (colorTarget?.color ?? NexusConfiguration.ChromaticPalette.cellIlluminated) : NexusConfiguration.ChromaticPalette.cellDormant
        node.childNode(withName: PrismGameScene.GridNodeNames.keypooOverlay)?.isHidden = !isVisible
        node.glowWidth = isVisible ? 8 : 0
    }

    func initiateRevelationPhase() {
        // Generate new pattern
        let illuminationCount = NexusConfiguration.illuminationQuantity(forStage: progressTracker.currentStage)
        activeMemoryColors = NexusConfiguration.activeMemoryColors(forStage: progressTracker.currentStage)
        objectiveColors = NexusConfiguration.targetMemoryColors(
            forStage: progressTracker.currentStage,
            illuminationCount: illuminationCount
        )
        gridModel.synthesizeRandomPattern(
            illuminationCount: illuminationCount,
            activeColors: activeMemoryColors,
            targetColors: objectiveColors
        )
        targetPattern = gridModel.copyPattern()
        targetPatternColors = gridModel.copyColorPattern()

        // Display pattern
        displayPatternOnGrid()
        updatePhaseHint(for: .revelation)

        // Wait for revelation duration
        let duration = NexusConfiguration.revelationDuration(forStage: progressTracker.currentStage)
        let waitAction = SKAction.wait(forDuration: duration)
        let transitionAction = SKAction.run { [weak self] in
            self?.stateMachine.transitionTo(.memorization)
        }

        run(SKAction.sequence([waitAction, transitionAction]))
    }

    func initiateMemorizationPhase() {
        // Clear the grid display
        clearGridDisplay()
        updatePhaseHint(for: .memorization)
        presentObjectivePrompt()

        // Short pause for memorization
        let waitAction = SKAction.wait(forDuration: 0.5)
        let transitionAction = SKAction.run { [weak self] in
            self?.stateMachine.transitionTo(.reconstruction)
        }

        run(SKAction.sequence([waitAction, transitionAction]))
    }

    func initiateReconstructionPhase() {
        // Clear player's grid model
        gridModel.clearAllIllumination()
        updatePhaseHint(for: .reconstruction)

        // Show confirm button
        confirmButton.isHidden = false
        confirmButton.alpha = 0
        confirmButton.run(SKAction.fadeIn(withDuration: 0.3))

        // Enable grid interaction
        isUserInteractionEnabled = true
    }

    func performValidation() {
        let isCorrect = gridModel.validateAgainst(selectedObjectivePattern())
        updatePhaseHint(for: .validation)

        if isCorrect {
            handleTriumph()
        } else {
            handleTermination()
        }
    }

    func handleTriumph() {
        stateMachine.transitionTo(.triumph)
        updatePhaseHint(for: .triumph)

        // Update progress
        progressTracker.registerTriumph()
        progressTracker.advanceToNextStage()
        refreshHUD()

        // Show success feedback
        displaySuccessAnimation()

        // Check if grid needs to be reconstructed
        let newGridSize = NexusConfiguration.gridDimensionality(forStage: progressTracker.currentStage)
        if newGridSize != gridModel.dimensionality {
            gridModel = MatrixGridModel(dimensionality: newGridSize)
            constructGrid()
        }

        // Continue to next level
        let waitAction = SKAction.wait(forDuration: 1.5)
        let nextLevelAction = SKAction.run { [weak self] in
            self?.confirmButton.isHidden = true
            self?.stateMachine.transitionTo(.revelation)
        }

        run(SKAction.sequence([waitAction, nextLevelAction]))
    }

    func handleTermination() {
        stateMachine.transitionTo(.termination)
        updatePhaseHint(for: .termination)

        // Stop timer if in Chronos mode
        chronosTimer?.terminateCountdown()

        // Save game record to history
        HistoryArchive.shared.saveRecord(
            mode: gameMode,
            score: progressTracker.accumulatedScore,
            stage: progressTracker.currentStage
        )

        // Show game over modal
        displayGameOverModal()
    }

    func displayPatternOnGrid() {
        for row in 0..<gridModel.dimensionality {
            for col in 0..<gridModel.dimensionality {
                let coordinate = CellularCoordinate(row: row, column: col)
                let cellNode = gridCellNodes[row][col]

                if gridModel.isCellIlluminated(at: coordinate) {
                    illuminateCellNode(cellNode, colorTarget: colorForCell(at: coordinate))
                } else {
                    deilluminateCellNode(cellNode)
                }
            }
        }
    }

    func clearGridDisplay() {
        for row in 0..<gridModel.dimensionality {
            for col in 0..<gridModel.dimensionality {
                let cellNode = gridCellNodes[row][col]
                deilluminateCellNode(cellNode)
            }
        }
    }

    func illuminateCellNode(_ node: SKShapeNode, animated: Bool = true) {
        applyAppearance(to: node, colorTarget: .blue, isVisible: true, animated: animated)
    }

    func illuminateCellNode(
        _ node: SKShapeNode,
        colorTarget: NexusConfiguration.MemoryColorTarget?,
        animated: Bool = true
    ) {
        applyAppearance(to: node, colorTarget: colorTarget, isVisible: true, animated: animated)
    }

    func deilluminateCellNode(_ node: SKShapeNode, animated: Bool = true) {
        applyAppearance(to: node, colorTarget: nil, isVisible: false, animated: animated)
    }

    func refreshHUD() {
        stageLabel.text = "Stage \(progressTracker.currentStage)"
        scoreLabel.text = "Score: \(progressTracker.accumulatedScore)"
    }

    func displaySuccessAnimation() {
        // Flash all correct cells
        for row in 0..<gridModel.dimensionality {
            for col in 0..<gridModel.dimensionality {
                let coordinate = CellularCoordinate(row: row, column: col)
                if targetPattern.contains(coordinate) {
                    let cellNode = gridCellNodes[row][col]

                    let flashAction = SKAction.sequence([
                        SKAction.run { cellNode.fillColor = .white },
                        SKAction.wait(forDuration: 0.2),
                        SKAction.run { [weak self] in
                            self?.applyAppearance(
                                to: cellNode,
                                colorTarget: self?.colorForCell(at: coordinate),
                                isVisible: true,
                                animated: false
                            )
                        },
                        SKAction.wait(forDuration: 0.2)
                    ])

                    cellNode.run(SKAction.repeat(flashAction, count: 2))
                }
            }
        }
    }

    func displayGameOverModal() {
        let modal = LuminaModalView(
            size: size,
            title: "Game Over",
            message: "Final Score: \(progressTracker.accumulatedScore)\nStage Reached: \(progressTracker.currentStage)",
            buttonText: "Return to Menu"
        )

        modal.actionCallback = { [weak self] in
            modal.dismissModal { [weak self] in
                self?.orchestrator?.returnToMainMenu()
            }
        }

        addChild(modal)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if modal is present
        for child in children {
            if let modal = child as? LuminaModalView {
                if modal.handleTouch(at: location) {
                    return
                }
            }
        }

        // Check all touched nodes
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            // Handle back button
            if node.name == "backButton" || node.parent?.name == "backButton" {
                handleBackButtonTap()
                return
            }

            // Handle confirm button
            if (node.name == "confirmButton" || node.parent?.name == "confirmButton") && !confirmButton.isHidden {
                handleConfirmButtonTap()
                return
            }
        }

        // Handle grid cell taps during reconstruction phase
        if stateMachine.currentPhase == .reconstruction {
            handleGridCellTap(at: location)
        }
    }

    func handleBackButtonTap() {
        // Animate button
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        backButton.run(SKAction.sequence([scaleDown, scaleUp]))

        // Haptic feedback
        ResonanceAudioManager.shared.triggerLightHaptic()

        // Show pause modal
        showPauseModal()
    }

    func showPauseModal() {
        chronosTimer?.terminateCountdown()

        let modal = LuminaModalView(
            size: size,
            title: "Paused",
            message: "Return to main menu?",
            buttonText: "Main Menu"
        )

        modal.actionCallback = { [weak self] in
            modal.dismissModal { [weak self] in
                self?.orchestrator?.returnToMainMenu()
            }
        }
        modal.zPosition = 200
        addChild(modal)
    }

    func handleConfirmButtonTap() {
        // Animate button
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        confirmButton.run(SKAction.sequence([scaleDown, scaleUp]))

        // Validate
        stateMachine.transitionTo(.validation)
    }

    func handleGridCellTap(at location: CGPoint) {
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            let tappableNode = node.name?.hasPrefix("cell_") == true ? node : node.parent

            if let nodeName = tappableNode?.name, nodeName.hasPrefix("cell_") {
                let components = nodeName.split(separator: "_")
                if components.count == 3,
                   let row = Int(components[1]),
                   let col = Int(components[2]) {

                    let coordinate = CellularCoordinate(row: row, column: col)
                    gridModel.toggleCellIllumination(at: coordinate)

                    let cellNode = gridCellNodes[row][col]
                    if gridModel.isCellIlluminated(at: coordinate) {
                        illuminateCellNode(cellNode, colorTarget: colorForCell(at: coordinate))
                    } else {
                        deilluminateCellNode(cellNode)
                    }

                    return
                }
            }
        }
    }
}
