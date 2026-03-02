import SpriteKit

class FireballNode: SKSpriteNode {

    private let speed: CGFloat = 380
    private let lifetime: TimeInterval = 4.0
    let firedByPlayer: Bool

    init(firedByPlayer: Bool) {
        self.firedByPlayer = firedByPlayer
        let size = CGSize(width: 12, height: 12)
        let color: UIColor = firedByPlayer
            ? UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1)   // orange — player fireball
            : UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1)   // red   — enemy fireball
        super.init(texture: nil, color: color, size: size)
        name = firedByPlayer ? "playerFireball" : "enemyFireball"
        setupPhysics(firedByPlayer: firedByPlayer)
        addGlow()
        scheduleDestroy()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysics(firedByPlayer: Bool) {
        physicsBody = SKPhysicsBody(circleOfRadius: 6)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0

        if firedByPlayer {
            physicsBody?.categoryBitMask    = PhysicsCategory.fireball
            physicsBody?.contactTestBitMask = PhysicsCategory.enemy
            physicsBody?.collisionBitMask   = PhysicsCategory.none
        } else {
            // Enemy projectile hits players
            physicsBody?.categoryBitMask    = PhysicsCategory.fireball
            physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
            physicsBody?.collisionBitMask   = PhysicsCategory.none
        }
    }

    private func addGlow() {
        let core = SKShapeNode(circleOfRadius: 4)
        core.fillColor = .white
        core.strokeColor = .clear
        core.alpha = 0.8
        addChild(core)
    }

    func launch(direction: CGFloat) {
        physicsBody?.velocity = CGVector(dx: direction * speed, dy: 0)
    }

    private func scheduleDestroy() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: lifetime),
            SKAction.removeFromParent()
        ]))
    }

    func hit() {
        // Burst particle-like flash before removing
        let flash = SKAction.sequence([
            SKAction.scale(to: 2.0, duration: 0.05),
            SKAction.fadeOut(withDuration: 0.08),
            SKAction.removeFromParent()
        ])
        run(flash)
    }
}
