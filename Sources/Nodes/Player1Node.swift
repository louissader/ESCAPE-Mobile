import SpriteKit

class Player1Node: PlayerNode {

    // MARK: - Shooting
    var canShoot = false
    var shootCooldown: TimeInterval = 0
    private let shootCooldownDuration: TimeInterval = 0.35

    // MARK: - Textures
    private let atlas = SKTextureAtlas(named: "Player")
    private var idleTexture: SKTexture!
    private var walkFrames: [SKTexture] = []
    private var jumpTexture: SKTexture!
    private var deadTexture: SKTexture!
    private var shootTexture: SKTexture!

    private var currentAnim = ""

    init() {
        super.init(color: .clear, size: CGSize(width: 32, height: 32))
        name = "player1"
        setupTextures()
        setupPhysicsCategories()
        playIdle()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Textures setup

    private func setupTextures() {
        // Pixel art — use .nearest to keep crisp edges
        func crisp(_ name: String) -> SKTexture {
            let t = atlas.textureNamed(name)
            t.filteringMode = .nearest
            return t
        }

        idleTexture  = crisp("idle")
        jumpTexture  = crisp("jump")
        deadTexture  = crisp("dead")
        shootTexture = crisp("shoot")
        walkFrames   = ["walk_01", "walk_02", "walk_03"].map { crisp($0) }

        texture = idleTexture
        color   = .clear       // clear color so texture shows through
        colorBlendFactor = 0
    }

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

    // MARK: - Animations

    func updateAnimation(velocityX: CGFloat) {
        if isDead {
            playDead(); return
        }
        if !isGrounded {
            playJump(); return
        }
        if abs(velocityX) > 10 {
            playWalk()
        } else {
            playIdle()
        }
    }

    private func playIdle() {
        guard currentAnim != "idle" else { return }
        currentAnim = "idle"
        removeAction(forKey: "anim")
        texture = idleTexture
    }

    private func playWalk() {
        guard currentAnim != "walk" else { return }
        currentAnim = "walk"
        removeAction(forKey: "anim")
        let anim = SKAction.animate(with: walkFrames, timePerFrame: 0.12)
        run(SKAction.repeatForever(anim), withKey: "anim")
    }

    private func playJump() {
        guard currentAnim != "jump" else { return }
        currentAnim = "jump"
        removeAction(forKey: "anim")
        texture = jumpTexture
    }

    private func playDead() {
        guard currentAnim != "dead" else { return }
        currentAnim = "dead"
        removeAction(forKey: "anim")
        texture = deadTexture
    }

    private func playShootAnim() {
        texture = shootTexture
        let restore = SKAction.sequence([
            SKAction.wait(forDuration: 0.12),
            SKAction.run { [weak self] in
                self?.currentAnim = ""   // allow next updateAnimation to re-pick
            }
        ])
        run(restore, withKey: "shootAnim")
    }

    // MARK: - Power-up

    func collectPowerUp() {
        canShoot = true
        // Tint flash to signal power-up collected
        let flash = SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 0.6, duration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.3)
        ])
        run(flash)
    }

    // MARK: - Shoot

    func tryShoot(currentTime: TimeInterval) {
        guard canShoot, !isDead, currentTime > shootCooldown else { return }
        shootCooldown = currentTime + shootCooldownDuration
        playShootAnim()
        shoot()
    }

    private func shoot() {
        let fireball = FireballNode(firedByPlayer: true)
        let xOffset: CGFloat = isFacingRight ? (size.width / 2 + 8) : -(size.width / 2 + 8)
        fireball.position = CGPoint(x: position.x + xOffset, y: position.y + 2)
        fireball.launch(direction: isFacingRight ? 1 : -1)
        parent?.addChild(fireball)
    }
}
