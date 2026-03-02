import SpriteKit

class FireballNode: SKSpriteNode {

    private let moveSpeed: CGFloat = 380
    private let lifetime: TimeInterval = 4.0
    let firedByPlayer: Bool

    private static let itemAtlas = SKTextureAtlas(named: "Items")

    init(firedByPlayer: Bool) {
        self.firedByPlayer = firedByPlayer

        let frameName = firedByPlayer ? "fire-01" : "fire-01"
        let tex = FireballNode.itemAtlas.textureNamed(frameName)
        tex.filteringMode = .nearest

        super.init(texture: tex, color: .clear, size: CGSize(width: 16, height: 16))
        name = firedByPlayer ? "playerFireball" : "enemyFireball"

        // Tint enemy fireballs red
        if !firedByPlayer {
            color = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
            colorBlendFactor = 0.5
        }

        setupPhysics(firedByPlayer: firedByPlayer)
        startFlameAnimation()
        scheduleDestroy()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysics(firedByPlayer: Bool) {
        physicsBody = SKPhysicsBody(circleOfRadius: 6)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask    = PhysicsCategory.fireball
        if firedByPlayer {
            physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        } else {
            physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        }
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    private func startFlameAnimation() {
        let frames = ["fire-01", "fire-02", "fire-03"].map { name -> SKTexture in
            let t = FireballNode.itemAtlas.textureNamed(name)
            t.filteringMode = .nearest
            return t
        }
        let anim = SKAction.animate(with: frames, timePerFrame: 0.08)
        run(SKAction.repeatForever(anim), withKey: "flame")
    }

    func launch(direction: CGFloat) {
        physicsBody?.velocity = CGVector(dx: direction * moveSpeed, dy: 0)
        xScale = direction < 0 ? -abs(xScale) : abs(xScale)
    }

    private func scheduleDestroy() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: lifetime),
            SKAction.removeFromParent()
        ]))
    }

    func hit() {
        removeAllActions()
        run(SKAction.sequence([
            SKAction.scale(to: 2.0, duration: 0.05),
            SKAction.fadeOut(withDuration: 0.08),
            SKAction.removeFromParent()
        ]))
    }
}
