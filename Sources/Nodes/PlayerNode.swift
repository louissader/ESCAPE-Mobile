import SpriteKit

/// Base class for both players.  Handles movement, jumping, health, and death/respawn.
class PlayerNode: SKSpriteNode {

    // MARK: - Constants
    let maxHP: CGFloat = 100
    let moveSpeed: CGFloat = 180         // pts/sec
    let jumpImpulse: CGFloat = 500
    let doubleJumpImpulse: CGFloat = 420
    let gravityScale: CGFloat = 1.0

    // MARK: - State
    var hp: CGFloat = 100
    var isDead = false
    var isGrounded = false
    var groundContactCount = 0 {
        didSet { isGrounded = groundContactCount > 0 }
    }
    var canDoubleJump = true
    var didDoubleJump = false
    var isFacingRight = true
    var disableControls = false

    private var spawnPosition: CGPoint = .zero
    private var hitCooldown: TimeInterval = 0
    private let hitCooldownDuration: TimeInterval = 1.0

    // MARK: - Init
    init(color: SKColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0.3
        physicsBody?.friction = 0.7
        physicsBody?.mass = 1.0
    }

    func setSpawnPosition(_ pos: CGPoint) {
        spawnPosition = pos
    }

    // MARK: - Movement

    func move(direction: CGFloat) {
        guard !disableControls, !isDead else { return }
        let vx = direction * moveSpeed
        if let body = physicsBody {
            body.velocity = CGVector(dx: vx, dy: body.velocity.dy)
        }

        if direction != 0 {
            isFacingRight = direction > 0
            xScale = isFacingRight ? abs(xScale) : -abs(xScale)
        }
    }

    func jump() {
        guard !disableControls, !isDead else { return }
        if isGrounded {
            if let body = physicsBody {
                body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
            }
            physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
            didDoubleJump = false
        } else if canDoubleJump && !didDoubleJump {
            if let body = physicsBody {
                body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
            }
            physicsBody?.applyImpulse(CGVector(dx: 0, dy: doubleJumpImpulse))
            didDoubleJump = true
        }
    }

    // MARK: - Health

    func takeDamage(_ amount: CGFloat, currentTime: TimeInterval) {
        guard !isDead, currentTime > hitCooldown else { return }
        hp -= amount
        hitCooldown = currentTime + hitCooldownDuration
        flashHit()
        if hp <= 0 { die() }
    }

    func heal(_ amount: CGFloat) {
        hp = min(hp + amount, maxHP)
    }

    private func flashHit() {
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.05),
            SKAction.colorize(with: color, colorBlendFactor: 0, duration: 0.05),
        ])
        run(SKAction.repeat(flash, count: 3))
    }

    // MARK: - Death & Respawn

    func die() {
        guard !isDead else { return }
        isDead = true
        disableControls = true
        physicsBody?.velocity = .zero
        alpha = 0.3

        let wait = SKAction.wait(forDuration: 2.0)
        let respawn = SKAction.run { [weak self] in self?.respawn() }
        run(SKAction.sequence([wait, respawn]))
    }

    func respawn() {
        isDead = false
        disableControls = false
        hp = maxHP
        alpha = 1.0
        position = spawnPosition
        physicsBody?.velocity = .zero
    }

    // MARK: - Update (called from GameScene)

    func update(deltaTime: TimeInterval) {
        hitCooldown = max(0, hitCooldown - deltaTime)
    }
}
