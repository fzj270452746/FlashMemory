//
//  LuminaModalView.swift
//  FlashMemory
//
//  Custom modal dialog for game events
//

import SpriteKit

class LuminaModalView: SKNode {

    private var backgroundOverlay: SKShapeNode!
    private var modalContainer: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var messageLabel: SKLabelNode!
    private var actionButton: SKShapeNode!
    private var actionButtonLabel: SKLabelNode!

    var actionCallback: (() -> Void)?

    init(size: CGSize, title: String, message: String, buttonText: String) {
        super.init()

        constructModal(size: size, title: title, message: message, buttonText: buttonText)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func constructModal(size: CGSize, title: String, message: String, buttonText: String) {
        let layoutHelper = AdaptiveLayoutHelper.shared

        // Semi-transparent background
        backgroundOverlay = SKShapeNode(rectOf: size)
        backgroundOverlay.fillColor = UIColor(white: 0, alpha: 0.7)
        backgroundOverlay.strokeColor = .clear
        backgroundOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundOverlay.zPosition = 100
        addChild(backgroundOverlay)

        // Modal container - adaptive sizing
        let modalWidth: CGFloat = min(size.width * 0.85, 320)
        let modalHeight: CGFloat = layoutHelper.isSmallDevice ? 280 : 300

        modalContainer = SKShapeNode(rectOf: CGSize(width: modalWidth, height: modalHeight),
                                    cornerRadius: 20)
        modalContainer.fillColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        modalContainer.strokeColor = NexusConfiguration.ChromaticPalette.primaryGradientStart
        modalContainer.lineWidth = 3
        modalContainer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        modalContainer.zPosition = 101
        addChild(modalContainer)

        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = title
        titleLabel.fontSize = layoutHelper.calculateFontSize(26)
        titleLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        titleLabel.position = CGPoint(x: 0, y: modalHeight * 0.35)
        titleLabel.verticalAlignmentMode = .center
        modalContainer.addChild(titleLabel)

        // Message
        messageLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        messageLabel.text = message
        messageLabel.fontSize = layoutHelper.calculateFontSize(16)
        messageLabel.fontColor = NexusConfiguration.ChromaticPalette.textSecondary
        messageLabel.position = CGPoint(x: 0, y: 20)
        messageLabel.verticalAlignmentMode = .center
        messageLabel.numberOfLines = 5
        messageLabel.preferredMaxLayoutWidth = modalWidth - 40
        modalContainer.addChild(messageLabel)

        // Action button
        let buttonWidth = min(modalWidth * 0.7, 200)
        let buttonHeight = layoutHelper.calculateButtonHeight()

        actionButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight),
                                  cornerRadius: buttonHeight / 2)
        actionButton.fillColor = NexusConfiguration.ChromaticPalette.primaryGradientStart
        actionButton.strokeColor = .clear
        actionButton.position = CGPoint(x: 0, y: -modalHeight * 0.28)
        actionButton.name = "modalActionButton"
        modalContainer.addChild(actionButton)

        actionButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        actionButtonLabel.text = buttonText
        actionButtonLabel.fontSize = layoutHelper.calculateFontSize(18)
        actionButtonLabel.fontColor = .white
        actionButtonLabel.verticalAlignmentMode = .center
        actionButton.addChild(actionButtonLabel)

        // Entrance animation
        modalContainer.setScale(0.5)
        modalContainer.alpha = 0
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.3)
        scaleAction.timingMode = .easeOut
        let fadeAction = SKAction.fadeIn(withDuration: 0.3)
        modalContainer.run(SKAction.group([scaleAction, fadeAction]))
    }

    func handleTouch(at location: CGPoint) -> Bool {
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "modalActionButton" {
                animateButtonPress()
                return true
            }
        }

        return false
    }

    private func animateButtonPress() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)

        actionButton.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
            self?.actionCallback?()
        }
    }

    func dismissModal(completion: (() -> Void)? = nil) {
        let scaleAction = SKAction.scale(to: 0.5, duration: 0.2)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)

        modalContainer.run(SKAction.group([scaleAction, fadeAction])) { [weak self] in
            self?.removeFromParent()
            completion?()
        }
    }
}
