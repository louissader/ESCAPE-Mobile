import SpriteKit

/// Player 1 — The Shooter.
/// Translates Unity's PlayerCharacterOne: movement, double-jump, fireball shooting.
class Player1Node: PlayerNode {

    // MARK: - Shooting
    var canShoot = false
    var shootCooldown: TimeInterval = 0
    private let shootCooldownDuration: TimeInterval = 0.35

    weak var gameScene: SKScene?

    // Visual indicator for shoot ability
    private var powerUpGlow: SKShapeNode?

    init() {
        super.init(color: UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1), // orange
                   size: CGSize(width: 28, height: 38))
        name = "player1"
        setupPhysicsCategories()
        addFace()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysicsCategories() {
        physicsBody?.categoryBitMask    = PhysicsCategory.player1
        physicsBody?.contactTestBitMask = PhysicsCategory.ground  |
                                          PhysicsCategory.enemy   |
                                          PhysicsCategory.lava    |
                                          PhysicsCategory.exit    |
                                          PhysicsCategory.platform2
        physicsBody?.collisionBitMask   = PhysicsCategory.ground  |
                                          PhysicsCategory.bridge  |
                                          PhysicsCategory.platform2
    }

    private func addFace() {
        // Simple dot-eyes to make the character recognizable
        let eyeL = SKShapeNode(circleOfRadius: 3)
        eyeL.fillColor = .white; eyeL.strokeColor = .clear
        eyeL.position = CGPoint(x: -6, y: 8)
        addChild(eyeL)

        let eyeR = SKShapeNode(circleOfRadius: 3)
        eyeR.fillColor = .white; eyeR.strokeColor = .clear
        eyeR.position = CGPoint(x: 6, y: 8)
        addChild(eyeR)
    }

    // MARK: - Power-up

    func collectPowerUp() {
        canShoot = true
        // Visual glow
        let glow = SKShapeNode(rectOf: CGSize(width: size.width + 8, height: size.height + 8), cornerRadius: 4)
        glow.strokeColor = .yellow
        glow.lineWidth = 2
        glow.fillColor = .clear
        glow.alpha = 0.7
        glow.name = "powerGlow"
        addChild(glow)
        powerUpGlow = glow

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 0.8, duration: 0.5)
        ])
        glow.run(SKAction.repeatForever(pulse))
    }

    // MARK: - Shoot

    func tryShoot(currentTime: TimeInterval) {
        guard canShoot, !isDead, currentTime > shootCooldown else { return }
        shootCooldown = currentTime + shootCooldownDuration
        shoot()
    }

    private func shoot() {
        let fireball = FireballNode(firedByPlayer: true)
        let xOffset: CGFloat = isFacingRight ? (size.width / 2 + 8) : -(size.width / 2 + 8)
        fireball.position = CGPoint(x: position.x + xOffset, y: position.y + 5)
        fireball.launch(direction: isFacingRight ? 1 : -1)
        parent?.addChild(fireball)
    }
}
