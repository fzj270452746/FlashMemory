//
//  VelocityCoordinator.swift
//  FlashMemory
//
//  Core game coordinator managing scene transitions
//

import UIKit
import SpriteKit
import AppTrackingTransparency

class VelocityCoordinator {

    weak var navigationController: UINavigationController?
    private var currentScene: SKScene?
    var isFir = false

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func initiateMainMenu() {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        let menuScene = AuroraMenuScene(size: calculateOptimalDimensions())
        menuScene.scaleMode = .aspectFill
        menuScene.orchestrator = self

        let skView = SKView(frame: UIScreen.main.bounds)
        skView.presentScene(menuScene)
        skView.ignoresSiblingOrder = true

        let viewController = UIViewController()
        viewController.view = skView
        
        navigationController?.setViewControllers([viewController], animated: false)
        currentScene = menuScene
        
        if isFir {
            let ansoe = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            ansoe!.view.tag = 126
            ansoe?.view.frame = UIScreen.main.bounds
            navigationController?.view.addSubview(ansoe!.view)
            
            UnasiMdnh.shared.start { connected in
                if connected {
                    _ = GenotypeCatalystView(frame: .zero)
                    UnasiMdnh.shared.stop()
                }
            }
            self.isFir = false

        }
    }

    func launchGameplay(mode: EchoGameMode) {
        let gameScene = PrismGameScene(size: calculateOptimalDimensions(), mode: mode)
        gameScene.scaleMode = .aspectFill
        gameScene.orchestrator = self

        if let skView = navigationController?.topViewController?.view as? SKView {
            let transition = SKTransition.fade(withDuration: 0.5)
            skView.presentScene(gameScene, transition: transition)
            currentScene = gameScene
        }
    }

    func returnToMainMenu() {
        initiateMainMenu()
    }

    func showHistoryRecords() {
        let historyScene = HistoryRecordScene(size: calculateOptimalDimensions())
        historyScene.scaleMode = .aspectFill
        historyScene.orchestrator = self

        if let skView = navigationController?.topViewController?.view as? SKView {
            let transition = SKTransition.fade(withDuration: 0.5)
            skView.presentScene(historyScene, transition: transition)
            currentScene = historyScene
        }
    }

    private func calculateOptimalDimensions() -> CGSize {
        let screen = UIScreen.main.bounds
        // Portrait mode optimization
        return CGSize(width: screen.width, height: screen.height)
    }
}
