//
//  AuroraMenuScene.swift
//  FlashMemory
//
//  Main menu scene
//

import SpriteKit

class AuroraMenuScene: SKScene {

    weak var orchestrator: VelocityCoordinator?

    private var titleLabel: SKLabelNode!
    private var modeButtons: [SKShapeNode] = []
    private var historyButton: SKShapeNode!
    private var howToPlayButton: SKShapeNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        configureScene()
        constructMenuInterface()
    }

    private func configureScene() {
        backgroundColor = NexusConfiguration.ChromaticPalette.backgroundDark
    }

    private func constructMenuInterface() {
        let layoutHelper = AdaptiveLayoutHelper.shared

        // Title - 限制宽度避免超出边界
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "FLASH MEMORY"
        titleLabel.fontSize = layoutHelper.calculateFontSize(38)
        titleLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        titleLabel.preferredMaxLayoutWidth = size.width * 0.9 // 限制最大宽度
        titleLabel.numberOfLines = 1
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)

        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitleLabel.text = "Test Your Memory"
        subtitleLabel.fontSize = layoutHelper.calculateFontSize(16)
        subtitleLabel.fontColor = NexusConfiguration.ChromaticPalette.textSecondary
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        addChild(subtitleLabel)

        // Animated title effect
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        titleLabel.run(SKAction.repeatForever(pulseAction))

        // Calculate button positions based on screen size
        let topSafeArea = layoutHelper.topSafeArea()
        let bottomSafeArea = layoutHelper.bottomSafeArea()
        let availableHeight = size.height - topSafeArea - bottomSafeArea - 200 // Reserve space for title

        let buttonSpacing = availableHeight / 4
        let startY = bottomSafeArea + buttonSpacing + 60 // Add extra space for How to Play button

        // Mode buttons
        let modes: [EchoGameMode] = [.odyssey, .chronos, .zenith]

        for (index, mode) in modes.enumerated() {
            let yPosition = startY + CGFloat(2 - index) * buttonSpacing
            let button = createModeButton(mode: mode, yPosition: yPosition)
            modeButtons.append(button)
            addChild(button)
        }

        // History button (top right)
        constructHistoryButton()

        // How to Play button (bottom)
        constructHowToPlayButton()
    }

    private func createModeButton(mode: EchoGameMode, yPosition: CGFloat) -> SKShapeNode {
        let layoutHelper = AdaptiveLayoutHelper.shared
        let buttonWidth = layoutHelper.calculateButtonWidth(sceneWidth: size.width)
        let buttonHeight = layoutHelper.calculateButtonHeight()

        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight),
                                cornerRadius: buttonHeight / 2)
        button.position = CGPoint(x: size.width / 2, y: yPosition)
        button.name = "mode_\(mode)"

        // Gradient-like effect with color
        switch mode {
        case .odyssey:
            button.fillColor = NexusConfiguration.ChromaticPalette.primaryGradientStart
        case .chronos:
            button.fillColor = NexusConfiguration.ChromaticPalette.secondaryGradientStart
        case .zenith:
            button.fillColor = NexusConfiguration.ChromaticPalette.accentGradientStart
        }

        button.strokeColor = .clear

        // Title
        let buttonTitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        buttonTitleLabel.text = mode.displayTitle
        buttonTitleLabel.fontSize = layoutHelper.calculateFontSize(20)
        buttonTitleLabel.fontColor = .white
        buttonTitleLabel.position = CGPoint(x: 0, y: 8)
        buttonTitleLabel.verticalAlignmentMode = .center
        button.addChild(buttonTitleLabel)

        // Description
        let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        descLabel.text = mode.descriptionText
        descLabel.fontSize = layoutHelper.calculateFontSize(13)
        descLabel.fontColor = UIColor(white: 1.0, alpha: 0.8)
        descLabel.position = CGPoint(x: 0, y: -12)
        descLabel.verticalAlignmentMode = .center
        button.addChild(descLabel)

        return button
    }

    private func constructHistoryButton() {
        let layoutHelper = AdaptiveLayoutHelper.shared
        let safeTop = layoutHelper.calculateHUDTopPosition(sceneHeight: size.height)
        let btnSize: CGFloat = 40

        historyButton = SKShapeNode(circleOfRadius: btnSize / 2)
        historyButton.position = CGPoint(x: size.width - 30, y: safeTop)
        historyButton.fillColor = UIColor(white: 1, alpha: 0.1)
        historyButton.strokeColor = UIColor(white: 1, alpha: 0.3)
        historyButton.lineWidth = 1
        historyButton.name = "historyButton"
        historyButton.zPosition = 20

        let historyIcon = layoutHelper.makeSymbolNode(
            systemName: "chart.bar.fill",
            pointSize: 18,
            weight: .semibold,
            color: .white
        )
        historyIcon.position = CGPoint(x: 0, y: 0)
        historyButton.addChild(historyIcon)

        addChild(historyButton)
    }

    private func constructHowToPlayButton() {
        let layoutHelper = AdaptiveLayoutHelper.shared
        let buttonWidth: CGFloat = 160
        let buttonHeight: CGFloat = 44
        let bottomSafeArea = layoutHelper.bottomSafeArea()

        howToPlayButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight),
                                      cornerRadius: buttonHeight / 2)
        howToPlayButton.position = CGPoint(x: size.width / 2, y: bottomSafeArea + 80)
        howToPlayButton.fillColor = UIColor(white: 0.2, alpha: 0.6)
        howToPlayButton.strokeColor = UIColor(white: 0.4, alpha: 0.8)
        howToPlayButton.lineWidth = 1.5
        howToPlayButton.name = "howToPlayButton"
        howToPlayButton.zPosition = 10

        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.text = "How to Play"
        label.fontSize = layoutHelper.calculateFontSize(15)
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        howToPlayButton.addChild(label)

        addChild(howToPlayButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check modal first
        for child in children {
            if let modal = child as? LuminaModalView {
                if modal.handleTouch(at: location) {
                    return
                }
            }
        }

        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "historyButton" || node.parent?.name == "historyButton" {
                handleHistoryButtonTap()
                return
            }

            if node.name == "howToPlayButton" || node.parent?.name == "howToPlayButton" {
                handleHowToPlayButtonTap()
                return
            }

            if let nodeName = node.name, nodeName.hasPrefix("mode_") {
                handleButtonTap(node: node as? SKShapeNode)
                return
            }
        }
    }

    private func handleHistoryButtonTap() {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        historyButton.run(SKAction.sequence([scaleDown, scaleUp]))

        ResonanceAudioManager.shared.triggerLightHaptic()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.orchestrator?.showHistoryRecords()
        }
    }

    private func handleHowToPlayButtonTap() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        howToPlayButton.run(SKAction.sequence([scaleDown, scaleUp]))

        ResonanceAudioManager.shared.triggerLightHaptic()

        showHowToPlayModal()
    }

    private func showHowToPlayModal() {
        let modal = LuminaModalView(
            size: size,
            title: "How to Play",
            message: "1. Watch the pattern light up\n2. Memorize the positions\n3. Recreate the pattern\n4. Progress through levels!",
            buttonText: "Got It"
        )

        modal.actionCallback = { [weak self] in
            modal.dismissModal()
        }
        modal.zPosition = 200
        addChild(modal)
    }

    private func handleButtonTap(node: SKShapeNode?) {
        guard let button = node, let name = button.name else { return }

        // Button press animation
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(SKAction.sequence([scaleDown, scaleUp]))

        // Determine mode
        var selectedMode: EchoGameMode?
        if name.contains("odyssey") {
            selectedMode = .odyssey
        } else if name.contains("chronos") {
            selectedMode = .chronos
        } else if name.contains("zenith") {
            selectedMode = .zenith
        }

        if let mode = selectedMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.orchestrator?.launchGameplay(mode: mode)
            }
        }
    }
}
