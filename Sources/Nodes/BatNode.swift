import SpriteKit

/// Flying enemy — translates Unity's Bat.cs.
/// Floats randomly within a radius and periodically shoots at the active player.
class BatNode: SKSpriteNode {

    private let moveRange: CGFloat = 60
    private let shootInterval: TimeInterval = 2.5
    private let shootRange: CGFloat = 400
    private var startPosition: CGPoint = .zero

    weak var gameScene: SKScene?

    // MARK: - Init

    init() {
        super.init(texture: nil,
                   color: UIColor(red: 0.4, green: 0.1, blue: 0.5, alpha: 1),
                   size: CGSize(width: 24, height: 16))
        name = "bat"
        setupPhysics()
        addWings()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false          // kinematic — we move it manually
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player1   |
                                          PhysicsCategory.player2   |
                                          PhysicsCategory.fireball
        physicsBody?.collisionBitMask   = PhysicsCategory.none
    }

    private func addWings() {
        // Simple triangle shapes for wings
        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: 0, y: 0))
        wingPath.addLine(to: CGPoint(x: -14, y: 8))
        wingPath.addLine(to: CGPoint(x: -14, y: -4))
        wingPath.closeSubpath()

        let leftWing = SKShapeNode(path: wingPath)
        leftWing.fillColor = UIColor(red: 0.3, green: 0.05, blue: 0.4, alpha: 1)
        leftWing.strokeColor = .clear
        leftWing.position = CGPoint(x: -size.width / 2, y: 0)
        addChild(leftWing)

        let rightWingPath = CGMutablePath()
        rightWingPath.move(to: CGPoint(x: 0, y: 0))
        rightWingPath.addLine(to: CGPoint(x: 14, y: 8))
        rightWingPath.addLine(to: CGPoint(x: 14, y: -4))
        rightWingPath.closeSubpath()

        let rightWing = SKShapeNode(path: rightWingPath)
        rightWing.fillColor = UIColor(red: 0.3, green: 0.05, blue: 0.4, alpha: 1)
        rightWing.strokeColor = .clear
        rightWing.position = CGPoint(x: size.width / 2, y: 0)
        addChild(rightWing)
    }

    // MARK: - Activation

    func activate(at position: CGPoint, in scene: SKScene) {
        self.gameScene = scene
        self.startPosition = position
        self.position = position
        startFloating()
        startShooting()
    }

    // MARK: - Floating behaviour (translates FloatRandomly coroutine)

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
        run(move, withKey: "moveTo")
    }

    // MARK: - Shooting behaviour (translates ShootFireballs coroutine)

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

        // Find nearest player within range
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

    // MARK: - Destruction

    func destroy() {
        removeAllActions()
        let burst = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.08),
            SKAction.fadeOut(withDuration: 0.12),
            SKAction.removeFromParent()
        ])
        run(burst)
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
