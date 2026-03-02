import SpriteKit

/// Translates Unity's Bridge.cs.
/// A toggleable platform activated by its paired LeverNode.
class BridgeNode: SKSpriteNode {

    private(set) var isActive = false
    let bridgeTag: String

    // MARK: - Init

    init(size: CGSize, tag: String) {
        self.bridgeTag = tag
        super.init(texture: nil,
                   color: UIColor(red: 0.5, green: 0.35, blue: 0.1, alpha: 1),
                   size: size)
        name = "bridge_\(tag)"
        setupPhysics(size: size)
        setActive(false) // starts hidden
        addWoodTexture(size: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysics(size: CGSize) {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.friction = 0.7
        physicsBody?.categoryBitMask    = PhysicsCategory.bridge
        physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        physicsBody?.collisionBitMask   = PhysicsCategory.player1 |
                                          PhysicsCategory.player2 |
                                          PhysicsCategory.platform2
    }

    private func addWoodTexture(size: CGSize) {
        // Simple plank lines
        let plankCount = Int(size.width / 16)
        for i in 0..<plankCount {
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: size.height - 4))
            line.fillColor = UIColor(red: 0.4, green: 0.27, blue: 0.07, alpha: 0.6)
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(i) * 16 - size.width / 2 + 8, y: 0)
            addChild(line)
        }
    }

    // MARK: - Toggle

    func setActive(_ active: Bool, animated: Bool = true) {
        isActive = active
        physicsBody?.categoryBitMask = active ? PhysicsCategory.bridge : PhysicsCategory.none
        physicsBody?.collisionBitMask = active
            ? PhysicsCategory.player1 | PhysicsCategory.player2 | PhysicsCategory.platform2
            : PhysicsCategory.none

        if animated {
            let targetAlpha: CGFloat = active ? 1.0 : 0.0
            let targetScaleX: CGFloat = active ? 1.0 : 0.0
            run(SKAction.group([
                SKAction.fadeAlpha(to: targetAlpha, duration: 0.2),
                SKAction.scaleX(to: targetScaleX, duration: 0.15)
            ]))
        } else {
            alpha = active ? 1.0 : 0.0
            xScale = active ? 1.0 : 0.0
        }
    }
}
