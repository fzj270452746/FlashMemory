//
//  AdaptiveLayoutHelper.swift
//  FlashMemory
//
//  Screen size adaptation utilities
//

import UIKit
import SpriteKit

class AdaptiveLayoutHelper {

    static let shared = AdaptiveLayoutHelper()

    private init() {}

    // MARK: - Device Detection

    var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    var isSmallDevice: Bool {
        // iPhone SE, 8, etc
        return screenHeight <= 667
    }

    var isMediumDevice: Bool {
        // iPhone 12, 13, 14, 15
        return screenHeight > 667 && screenHeight <= 844
    }

    var isLargeDevice: Bool {
        // iPhone Plus, Pro Max
        return screenHeight > 844
    }

    // MARK: - Scale Factors

    func scaleFactor() -> CGFloat {
        let baseWidth: CGFloat = 375.0 // iPhone SE/8 width
        let currentWidth = screenWidth
        let scale = currentWidth / baseWidth

        // Clamp scale factor for consistency
        return min(max(scale, 0.85), 1.15)
    }

    func fontScaleFactor() -> CGFloat {
        if isIPad {
            return 1.0 // iPad compatibility mode uses iPhone size
        }

        if isSmallDevice {
            return 0.9
        } else if isLargeDevice {
            return 1.1
        }
        return 1.0
    }

    func spacingScaleFactor() -> CGFloat {
        if isIPad {
            return 1.0
        }
        return scaleFactor()
    }

    // MARK: - Safe Area

    func safeAreaInsets() -> UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    func topSafeArea() -> CGFloat {
        let inset = safeAreaInsets().top
        return max(inset, 20) // Minimum 20pt
    }

    func bottomSafeArea() -> CGFloat {
        let inset = safeAreaInsets().bottom
        return max(inset, 20) // Minimum 20pt
    }

    // MARK: - Layout Calculations

    func calculateGridCellSize(gridDimension: Int, sceneSize: CGSize) -> CGFloat {
        // Calculate available space considering safe areas and margins
        let horizontalMargin: CGFloat = 32
        let verticalReserved: CGFloat = topSafeArea() + bottomSafeArea() + 200 // HUD + buttons

        let availableWidth = sceneSize.width - (horizontalMargin * 2)
        let availableHeight = sceneSize.height - verticalReserved

        // Use the smaller dimension to ensure grid fits
        let availableSpace = min(availableWidth, availableHeight)

        let spacing = NexusConfiguration.SpatialMetrics.cellSpacing
        let totalSpacing = CGFloat(gridDimension - 1) * spacing
        let cellSize = (availableSpace - totalSpacing) / CGFloat(gridDimension)

        // Maximum and minimum cell size constraints
        let maxCellSize: CGFloat = 85
        let minCellSize: CGFloat = 35

        return min(max(cellSize, minCellSize), maxCellSize)
    }

    func calculateButtonWidth(sceneWidth: CGFloat) -> CGFloat {
        let maxWidth: CGFloat = 280
        let minWidth: CGFloat = 200
        let calculatedWidth = sceneWidth * 0.7

        return min(max(calculatedWidth, minWidth), maxWidth)
    }

    func calculateButtonHeight() -> CGFloat {
        if isSmallDevice {
            return 50
        }
        return NexusConfiguration.SpatialMetrics.buttonHeight
    }

    func calculateFontSize(_ baseSize: CGFloat) -> CGFloat {
        return baseSize * fontScaleFactor()
    }

    func calculateHUDTopPosition(sceneHeight: CGFloat) -> CGFloat {
        return sceneHeight - topSafeArea() - 30
    }

    func calculateConfirmButtonBottomPosition() -> CGFloat {
        return bottomSafeArea() + 70
    }

    func calculateGridCenterY(sceneHeight: CGFloat) -> CGFloat {
        let topSpace = topSafeArea() + 80 // HUD space
        let bottomSpace = bottomSafeArea() + 120 // Button space
        let availableHeight = sceneHeight - topSpace - bottomSpace

        return bottomSpace + (availableHeight / 2)
    }

    // MARK: - iPad Compatibility

    func adjustForIPadCompatibilityMode() -> CGSize {
        // When iPhone app runs on iPad in compatibility mode
        if isIPad {
            // Return a centered portrait size
            let width = min(screenWidth, 414) // Max iPhone width
            let height = screenHeight
            return CGSize(width: width, height: height)
        }
        return CGSize(width: screenWidth, height: screenHeight)
    }

    // MARK: - Icon Rendering

    func makeSymbolNode(
        systemName: String,
        pointSize: CGFloat,
        weight: UIImage.SymbolWeight = .regular,
        color: UIColor = .white
    ) -> SKSpriteNode {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let image = UIImage(systemName: systemName, withConfiguration: configuration)?
            .withTintColor(color, renderingMode: .alwaysOriginal)

        let texture = image.map(SKTexture.init(image:)) ?? SKTexture()
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: pointSize, height: pointSize)
        node.color = .clear
        return node
    }
}
