//
//  PrismGameScene.swift
//  FlashMemory
//
//  Main gameplay SpriteKit scene
//

import SpriteKit
import AudioToolbox

class PrismGameScene: SKScene {

    enum GridNodeNames {
        static let keypooOverlay = "keypooOverlay"
    }

    weak var orchestrator: VelocityCoordinator?

    let gameMode: EchoGameMode
    var stateMachine: CascadeStateMachine!
    var gridModel: MatrixGridModel!
    var progressTracker: OdysseyProgressTracker!
    var chronosTimer: ChronosTimerController?

    var targetPattern: Set<CellularCoordinate> = []
    var targetPatternColors: [CellularCoordinate: NexusConfiguration.MemoryColorTarget] = [:]
    var activeMemoryColors: [NexusConfiguration.MemoryColorTarget] = [.blue]
    var objectiveColors: [NexusConfiguration.MemoryColorTarget] = [.blue]
    var gridCellNodes: [[SKShapeNode]] = []

    // UI Elements
    var hudContainer: SKNode!
    var stageLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode?
    var confirmButton: SKShapeNode!
    var confirmLabel: SKLabelNode!
    var phaseHintLabel: SKLabelNode!
    var backButton: SKShapeNode!
    var objectiveLabel: SKLabelNode!

    let gridContainerNode = SKNode()
    private var backgroundGradientNode: SKSpriteNode?
    private var activeModal: LuminaModalView?

    // Zenith mode: 0.5s display
    private var zenithDisplayDuration: TimeInterval = 0.5

    init(size: CGSize, mode: EchoGameMode) {
        self.gameMode = mode
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        configureScene()
        initializeGameComponents()
        constructUserInterface()
        commenceGameplay()
    }

    // MARK: - Setup

    private func configureScene() {
        backgroundColor = NexusConfiguration.ChromaticPalette.backgroundDark
        constructGradientBackground()
    }

    private func constructGradientBackground() {
        let gradientNode = SKSpriteNode(color: .clear, size: size)
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientNode.zPosition = -10

        // Subtle animated background circles
        for i in 0..<3 {
            let radius = CGFloat(120 + i * 80)
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.fillColor = .clear
            circle.strokeColor = UIColor(
                red: 0.3 + CGFloat(i) * 0.1,
                green: 0.4,
                blue: 1.0,
                alpha: 0.04
            )
            circle.lineWidth = 2
            circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
            circle.zPosition = -9

            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 2.0 + Double(i) * 0.5),
                SKAction.scale(to: 0.95, duration: 2.0 + Double(i) * 0.5)
            ])
            circle.run(SKAction.repeatForever(pulse))
            addChild(circle)
        }
    }

    private func initializeGameComponents() {
        stateMachine = CascadeStateMachine()
        stateMachine.phaseTransitionHandler = { [weak self] newPhase in
            self?.handlePhaseTransition(newPhase)
        }

        progressTracker = OdysseyProgressTracker()

        let gridSize = NexusConfiguration.gridDimensionality(forStage: progressTracker.currentStage)
        gridModel = MatrixGridModel(dimensionality: gridSize)

        if gameMode == .chronos {
            chronosTimer = ChronosTimerController(totalDuration: 60.0)
        }
    }

    private func constructUserInterface() {
        constructHUD()
        constructGrid()
        constructConfirmButton()
        constructPhaseHint()
        constructObjectiveLabel()
        constructBackButton()
    }

    private func constructHUD() {
        hudContainer = SKNode()
        hudContainer.zPosition = 10
        addChild(hudContainer)

        let layoutHelper = AdaptiveLayoutHelper.shared
        let safeTop = layoutHelper.calculateHUDTopPosition(sceneHeight: size.height)

        // HUD background bar
        let hudBarHeight: CGFloat = 60
        let hudBar = SKShapeNode(rectOf: CGSize(width: size.width, height: hudBarHeight))
        hudBar.fillColor = UIColor(white: 0, alpha: 0.3)
        hudBar.strokeColor = .clear
        hudBar.position = CGPoint(x: size.width / 2, y: size.height - hudBarHeight / 2)
        hudContainer.addChild(hudBar)

        // Stage label
        stageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        stageLabel.fontSize = layoutHelper.calculateFontSize(20)
        stageLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        stageLabel.position = CGPoint(x: size.width * 0.25, y: safeTop)
        stageLabel.horizontalAlignmentMode = .center
        stageLabel.verticalAlignmentMode = .center
        hudContainer.addChild(stageLabel)

        // Score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = layoutHelper.calculateFontSize(20)
        scoreLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        scoreLabel.position = CGPoint(x: size.width * 0.75, y: safeTop)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        hudContainer.addChild(scoreLabel)

        // Timer for Chronos mode
        if gameMode == .chronos {
            timerLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            timerLabel?.fontSize = layoutHelper.calculateFontSize(26)
            timerLabel?.fontColor = NexusConfiguration.ChromaticPalette.accentGradientStart
            timerLabel?.position = CGPoint(x: size.width / 2, y: safeTop)
            timerLabel?.horizontalAlignmentMode = .center
            timerLabel?.verticalAlignmentMode = .center
            hudContainer.addChild(timerLabel!)
        }

        refreshHUD()
    }

    func constructGrid() {
        gridContainerNode.removeAllChildren()
        gridCellNodes.removeAll()

        if gridContainerNode.parent == nil {
            addChild(gridContainerNode)
        }

        let layoutHelper = AdaptiveLayoutHelper.shared
        let gridSize = gridModel.dimensionality
        let cellSize = layoutHelper.calculateGridCellSize(gridDimension: gridSize, sceneSize: size)
        let spacing = NexusConfiguration.SpatialMetrics.cellSpacing
        let totalGridWidth = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing

        // Center grid horizontally
        let startX = (size.width - totalGridWidth) / 2

        // Center grid vertically in available space
        let gridCenterY = layoutHelper.calculateGridCenterY(sceneHeight: size.height)
        let startY = gridCenterY - (totalGridWidth / 2)

        for row in 0..<gridSize {
            var rowNodes: [SKShapeNode] = []

            for col in 0..<gridSize {
                let x = startX + CGFloat(col) * (cellSize + spacing)
                let y = startY + CGFloat(gridSize - 1 - row) * (cellSize + spacing)

                let cellNode = SKShapeNode(
                    rectOf: CGSize(width: cellSize, height: cellSize),
                    cornerRadius: min(NexusConfiguration.SpatialMetrics.cellCornerRadius, cellSize * 0.15)
                )
                cellNode.position = CGPoint(x: x + cellSize / 2, y: y + cellSize / 2)
                cellNode.fillColor = NexusConfiguration.ChromaticPalette.cellDormant
                cellNode.strokeColor = NexusConfiguration.ChromaticPalette.cellBorder
                cellNode.lineWidth = 1.5
                cellNode.name = "cell_\(row)_\(col)"
                cellNode.zPosition = 1

                let overlaySize = cellSize * 0.68
                let keypooOverlay = SKSpriteNode(imageNamed: "keypoo")
                keypooOverlay.name = GridNodeNames.keypooOverlay
                keypooOverlay.size = CGSize(width: overlaySize, height: overlaySize)
                keypooOverlay.position = .zero
                keypooOverlay.zPosition = 2
                keypooOverlay.alpha = 0.96
                keypooOverlay.isHidden = true
                cellNode.addChild(keypooOverlay)

                gridContainerNode.addChild(cellNode)
                rowNodes.append(cellNode)
            }

            gridCellNodes.append(rowNodes)
        }
    }

    private func constructConfirmButton() {
        let layoutHelper = AdaptiveLayoutHelper.shared
        let buttonWidth = layoutHelper.calculateButtonWidth(sceneWidth: size.width)
        let buttonHeight = layoutHelper.calculateButtonHeight()
        let buttonY = layoutHelper.calculateConfirmButtonBottomPosition()

        confirmButton = SKShapeNode(
            rectOf: CGSize(width: buttonWidth, height: buttonHeight),
            cornerRadius: buttonHeight / 2
        )
        confirmButton.position = CGPoint(x: size.width / 2, y: buttonY)
        confirmButton.fillColor = NexusConfiguration.ChromaticPalette.primaryGradientStart
        confirmButton.strokeColor = .clear
        confirmButton.name = "confirmButton"
        confirmButton.isHidden = true
        confirmButton.zPosition = 10

        confirmLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        confirmLabel.text = "CONFIRM"
        confirmLabel.fontSize = layoutHelper.calculateFontSize(18)
        confirmLabel.fontColor = .white
        confirmLabel.verticalAlignmentMode = .center
        confirmButton.addChild(confirmLabel)

        addChild(confirmButton)
    }

    private func constructPhaseHint() {
        let layoutHelper = AdaptiveLayoutHelper.shared

        phaseHintLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        phaseHintLabel.fontSize = layoutHelper.calculateFontSize(14)
        phaseHintLabel.fontColor = UIColor(white: 0.7, alpha: 1.0)
        phaseHintLabel.position = CGPoint(x: size.width / 2, y: layoutHelper.calculateConfirmButtonBottomPosition() + 80)
        phaseHintLabel.horizontalAlignmentMode = .center
        phaseHintLabel.zPosition = 10
        addChild(phaseHintLabel)
    }

    private func constructBackButton() {
        let layoutHelper = AdaptiveLayoutHelper.shared
        let btnSize: CGFloat = 40
        let topPosition = layoutHelper.calculateHUDTopPosition(sceneHeight: size.height)

        backButton = SKShapeNode(circleOfRadius: btnSize / 2)
        backButton.position = CGPoint(x: 30, y: topPosition)
        backButton.fillColor = UIColor(white: 1, alpha: 0.1)
        backButton.strokeColor = UIColor(white: 1, alpha: 0.3)
        backButton.lineWidth = 1
        backButton.name = "backButton"
        backButton.zPosition = 20
        backButton.isUserInteractionEnabled = false // 让触摸事件传递到场景

        let backIcon = layoutHelper.makeSymbolNode(
            systemName: "chevron.left",
            pointSize: 18,
            weight: .bold,
            color: .white
        )
        backIcon.position = CGPoint(x: -1, y: 0)
        backIcon.name = "backButtonLabel"
        backIcon.isUserInteractionEnabled = false
        backButton.addChild(backIcon)

        addChild(backButton)
    }

    private func constructObjectiveLabel() {
        let layoutHelper = AdaptiveLayoutHelper.shared

        objectiveLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        objectiveLabel.fontSize = layoutHelper.calculateFontSize(20)
        objectiveLabel.fontColor = NexusConfiguration.ChromaticPalette.textPrimary
        objectiveLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        objectiveLabel.horizontalAlignmentMode = .center
        objectiveLabel.verticalAlignmentMode = .center
        objectiveLabel.zPosition = 30
        objectiveLabel.alpha = 0
        objectiveLabel.isHidden = true
        addChild(objectiveLabel)
    }

    // MARK: - Game Flow

    private func commenceGameplay() {
        if gameMode == .chronos {
            startChronosTimer()
        }
        stateMachine.transitionTo(.revelation)
    }

    private func startChronosTimer() {
        chronosTimer?.initiateCountdown(
            updateHandler: { [weak self] remaining in
                self?.timerLabel?.text = String(format: "%.0f", remaining)
                if remaining <= 10 {
                    self?.timerLabel?.fontColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
                }
            },
            completion: { [weak self] in
                self?.handleTermination()
            }
        )
    }

    private func handlePhaseTransition(_ phase: QuantumGameState) {
        switch phase {
        case .dormant:
            break
        case .revelation:
            objectiveLabel.isHidden = true
            objectiveLabel.removeAllActions()
            objectiveLabel.alpha = 0
            initiateRevelationPhase()
        case .memorization:
            initiateMemorizationPhase()
        case .reconstruction:
            initiateReconstructionPhase()
        case .validation:
            performValidation()
        case .triumph:
            break
        case .termination:
            break
        }
    }

    // MARK: - Touch Handling
    // Touch handling is in PrismGameScene+Extensions.swift

    private func handleCellTap(nodeName: String) {
        guard stateMachine.currentPhase == .reconstruction else { return }

        let parts = nodeName.split(separator: "_")
        guard parts.count == 3,
              let row = Int(parts[1]),
              let col = Int(parts[2]) else { return }

        let coordinate = CellularCoordinate(row: row, column: col)
        gridModel.toggleCellIllumination(at: coordinate)

        let cellNode = gridCellNodes[row][col]
        if gridModel.isCellIlluminated(at: coordinate) {
            illuminateCellNode(cellNode)
            ResonanceAudioManager.shared.playTapSound()
            ResonanceAudioManager.shared.triggerLightHaptic()
        } else {
            deilluminateCellNode(cellNode)
            ResonanceAudioManager.shared.triggerLightHaptic()
        }
    }

    private func handleConfirmTap() {
        guard stateMachine.currentPhase == .reconstruction else { return }

        let scaleDown = SKAction.scale(to: 0.95, duration: 0.08)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.08)
        confirmButton.run(SKAction.sequence([scaleDown, scaleUp]))

        ResonanceAudioManager.shared.triggerMediumHaptic()
        stateMachine.transitionTo(.validation)
    }

    // MARK: - Layout Helpers

    func scaledFontSize(_ base: CGFloat) -> CGFloat {
        return AdaptiveLayoutHelper.shared.calculateFontSize(base)
    }
}
