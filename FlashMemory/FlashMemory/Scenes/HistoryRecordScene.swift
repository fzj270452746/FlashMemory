//
//  HistoryRecordScene.swift
//  FlashMemory
//
//  History records display scene
//

import SpriteKit

class HistoryRecordScene: SKScene {

    weak var orchestrator: VelocityCoordinator?

    private var backButton: SKShapeNode!
    private var segmentedControl: SKNode!
    private var selectedMode: EchoGameMode = .odyssey
    private var recordsContainer: SKNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        configureScene()
        constructInterface()
        displayRecords(for: selectedMode)
    }

    private func configureScene() {
        backgroundColor = NexusConfiguration.ChromaticPalette.backgroundDark
    }

    private func constructInterface() {
        let layoutHelper = AdaptiveLayoutHelper.shared
        let safeTop = layoutHelper.calculateHUDTopPosition(sceneHeight: size.height)

        // Back button
        let btnSize: CGFloat = 40
        backButton = SKShapeNode(circleOfRadius: btnSize / 2)
        backButton.position = CGPoint(x: 30, y: safeTop)
        backButton.fillColor = UIColor(white: 1, alpha: 0.1)
        backButton.strokeColor = UIColor(white: 1, alpha: 0.3)
        backButton.lineWidth = 1
        backButton.name = "backButton"
        backButton.zPosition = 20

        let backIcon = layoutHelper.makeSymbolNode(
            systemName: "chevron.left",
            pointSize: 18,
            weight: .bold,
            color: .white
        )
        backIcon.position = CGPoint(x: -1, y: 0)
        backButton.addChild(backIcon)
        addChild(backButton)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "History Records"
        titleLabel.fontSize = layoutHelper.calculateFontSize(28)
        titleLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        titleLabel.position = CGPoint(x: size.width / 2, y: safeTop)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        addChild(titleLabel)

        // Mode selector
        constructModeSelector(yPosition: safeTop - 60)

        // Records container
        recordsContainer = SKNode()
        recordsContainer.position = CGPoint(x: 0, y: 0)
        addChild(recordsContainer)
    }

    private func constructModeSelector(yPosition: CGFloat) {
        let layoutHelper = AdaptiveLayoutHelper.shared
        segmentedControl = SKNode()
        segmentedControl.position = CGPoint(x: size.width / 2, y: yPosition)

        let modes: [EchoGameMode] = [.odyssey, .chronos, .zenith]
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 36
        let spacing: CGFloat = 8
        let totalWidth = CGFloat(modes.count) * buttonWidth + CGFloat(modes.count - 1) * spacing
        let startX = -totalWidth / 2

        for (index, mode) in modes.enumerated() {
            let xPos = startX + CGFloat(index) * (buttonWidth + spacing) + buttonWidth / 2

            let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight),
                                    cornerRadius: buttonHeight / 2)
            button.position = CGPoint(x: xPos, y: 0)
            button.name = "modeSelector_\(mode)"

            if mode == selectedMode {
                button.fillColor = NexusConfiguration.ChromaticPalette.primaryGradientStart
            } else {
                button.fillColor = UIColor(white: 0.2, alpha: 0.5)
            }
            button.strokeColor = .clear

            let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
            label.text = modeName(mode)
            label.fontSize = layoutHelper.calculateFontSize(14)
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            button.addChild(label)

            segmentedControl.addChild(button)
        }

        addChild(segmentedControl)
    }

    private func displayRecords(for mode: EchoGameMode) {
        recordsContainer.removeAllChildren()

        let records = HistoryArchive.shared.loadRecords(for: mode)
        let layoutHelper = AdaptiveLayoutHelper.shared
        let startY = size.height - 200

        if records.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            emptyLabel.text = "No records yet"
            emptyLabel.fontSize = layoutHelper.calculateFontSize(16)
            emptyLabel.fontColor = NexusConfiguration.ChromaticPalette.textSecondary
            emptyLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
            emptyLabel.horizontalAlignmentMode = .center
            recordsContainer.addChild(emptyLabel)
            return
        }

        for (index, record) in records.enumerated() {
            let yPos = startY - CGFloat(index) * 70

            let recordNode = createRecordNode(record: record, index: index + 1, yPosition: yPos)
            recordsContainer.addChild(recordNode)
        }
    }

    private func createRecordNode(record: GameRecord, index: Int, yPosition: CGFloat) -> SKNode {
        let container = SKNode()
        let layoutHelper = AdaptiveLayoutHelper.shared

        let cardWidth = size.width * 0.9
        let cardHeight: CGFloat = 60

        // Background card
        let card = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight),
                              cornerRadius: 12)
        card.position = CGPoint(x: size.width / 2, y: yPosition)
        card.fillColor = UIColor(white: 0.15, alpha: 0.8)
        card.strokeColor = UIColor(white: 0.3, alpha: 0.5)
        card.lineWidth = 1
        container.addChild(card)

        // Rank
        let rankLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rankLabel.text = "#\(index)"
        rankLabel.fontSize = layoutHelper.calculateFontSize(18)
        rankLabel.fontColor = index <= 3 ? NexusConfiguration.ChromaticPalette.accentGradientStart : NexusConfiguration.ChromaticPalette.textSecondary
        rankLabel.position = CGPoint(x: size.width / 2 - cardWidth / 2 + 40, y: yPosition)
        rankLabel.horizontalAlignmentMode = .center
        rankLabel.verticalAlignmentMode = .center
        container.addChild(rankLabel)

        // Score
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "\(record.score)"
        scoreLabel.fontSize = layoutHelper.calculateFontSize(20)
        scoreLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        scoreLabel.position = CGPoint(x: size.width / 2 - cardWidth / 2 + 120, y: yPosition + 8)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        container.addChild(scoreLabel)

        // Stage
        let stageLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        stageLabel.text = "Stage \(record.stage)"
        stageLabel.fontSize = layoutHelper.calculateFontSize(13)
        stageLabel.fontColor = NexusConfiguration.ChromaticPalette.textSecondary
        stageLabel.position = CGPoint(x: size.width / 2 - cardWidth / 2 + 120, y: yPosition - 10)
        stageLabel.horizontalAlignmentMode = .left
        stageLabel.verticalAlignmentMode = .center
        container.addChild(stageLabel)

        // Date
        let dateLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        dateLabel.text = record.formattedDate
        dateLabel.fontSize = layoutHelper.calculateFontSize(12)
        dateLabel.fontColor = NexusConfiguration.ChromaticPalette.textSecondary
        dateLabel.position = CGPoint(x: size.width / 2 + cardWidth / 2 - 20, y: yPosition)
        dateLabel.horizontalAlignmentMode = .right
        dateLabel.verticalAlignmentMode = .center
        container.addChild(dateLabel)

        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "backButton" || node.parent?.name == "backButton" {
                handleBackButtonTap()
                return
            }

            if let nodeName = node.name, nodeName.hasPrefix("modeSelector_") {
                handleModeSelectorTap(node: node as? SKShapeNode)
                return
            }
        }
    }

    private func handleBackButtonTap() {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        backButton.run(SKAction.sequence([scaleDown, scaleUp]))

        ResonanceAudioManager.shared.triggerLightHaptic()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.orchestrator?.returnToMainMenu()
        }
    }

    private func handleModeSelectorTap(node: SKShapeNode?) {
        guard let button = node, let name = button.name else { return }

        var newMode: EchoGameMode?
        if name.contains("odyssey") {
            newMode = .odyssey
        } else if name.contains("chronos") {
            newMode = .chronos
        } else if name.contains("zenith") {
            newMode = .zenith
        }

        guard let mode = newMode, mode != selectedMode else { return }

        selectedMode = mode

        // Update button colors
        for child in segmentedControl.children {
            if let button = child as? SKShapeNode {
                if button.name?.contains(modeName(mode)) == true {
                    button.fillColor = NexusConfiguration.ChromaticPalette.primaryGradientStart
                } else {
                    button.fillColor = UIColor(white: 0.2, alpha: 0.5)
                }
            }
        }

        ResonanceAudioManager.shared.triggerLightHaptic()
        displayRecords(for: mode)
    }

    private func modeName(_ mode: EchoGameMode) -> String {
        switch mode {
        case .odyssey: return "Odyssey"
        case .chronos: return "Chronos"
        case .zenith: return "Zenith"
        }
    }
}
