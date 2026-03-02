import SpriteKit

class BatNode: SKSpriteNode {

    private let moveRange: CGFloat = 60
    private let shootInterval: TimeInterval = 2.5
    private let shootRange: CGFloat = 400
    private var startPosition: CGPoint = .zero

    weak var gameScene: SKScene?

    init() {
        let atlas = SKTextureAtlas(named: "Bat")
        let firstFrame = atlas.textureNamed("bat-fly-01")
        firstFrame.filteringMode = .nearest
        super.init(texture: firstFrame, color: .clear, size: CGSize(width: 32, height: 24))
        name = "bat"
        setupPhysics()
        startFlyAnimation(atlas: atlas)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 20))
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player1   |
                                          PhysicsCategory.player2   |
                                          PhysicsCategory.fireball
        physicsBody?.collisionBitMask   = PhysicsCategory.none
    }

    private func startFlyAnimation(atlas: SKTextureAtlas) {
        let frames = ["bat-fly-01", "bat-fly-02", "bat-fly-03"].map { name -> SKTexture in
            let t = atlas.textureNamed(name)
            t.filteringMode = .nearest
            return t
        }
        let anim = SKAction.animate(with: frames, timePerFrame: 0.1)
        run(SKAction.repeatForever(anim), withKey: "fly")
    }

    // MARK: - Activation

    func activate(at position: CGPoint, in scene: SKScene) {
        self.gameScene = scene
        self.startPosition = position
        self.position = position
        startFloating()
        startShooting()
    }

    private func startFloating() {
        let floatAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.moveToRandomPosition() },
                SKAction.wait(forDuration: 0.8, withRange: 0.4)
            ])
        )
        run(floatAction, withKey: "float")
    }

    private func moveToRandomPosition() {
        let dx = CGFloat.random(in: -moveRange...moveRange)
        let dy = CGFloat.random(in: -moveRange...moveRange)
        let target = CGPoint(x: startPosition.x + dx, y: startPosition.y + dy)
        let move = SKAction.move(to: target, duration: 0.7)
        move.timingMode = .easeInEaseOut
        // Flip sprite based on direction
        xScale = target.x < position.x ? -abs(xScale) : abs(xScale)
        run(move, withKey: "moveTo")
    }

    private func startShooting() {
        let shootAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: shootInterval, withRange: 0.5),
                SKAction.run { [weak self] in self?.shoot() }
            ])
        )
        run(shootAction, withKey: "shoot")
    }

    private func shoot() {
        guard let scene = gameScene else { return }
        let players = scene.children.compactMap { $0 as? PlayerNode }.filter { !$0.isDead }
        guard let target = players.min(by: {
            position.distance(to: $0.position) < position.distance(to: $1.position)
        }), position.distance(to: target.position) < shootRange else { return }

        let fireball = FireballNode(firedByPlayer: false)
        fireball.position = position
        let direction = (target.position - position).normalized
        fireball.physicsBody?.velocity = CGVector(dx: direction.x * 220, dy: direction.y * 220)
        scene.addChild(fireball)
    }

    func destroy() {
        removeAllActions()
        run(SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.07),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - CGPoint helpers
private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = x - other.x; let dy = y - other.y
        return sqrt(dx*dx + dy*dy)
    }
    var normalized: CGPoint {
        let len = sqrt(x*x + y*y)
        return len > 0 ? CGPoint(x: x/len, y: y/len) : .zero
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
