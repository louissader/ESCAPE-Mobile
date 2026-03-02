import SpriteKit

class Player2Node: PlayerNode {

    private(set) var isInPlatformForm = false
    private var originalSize: CGSize = .zero
    private let platformSize = CGSize(width: 80, height: 18)

    // MARK: - Textures (same atlas as P1, tinted blue to distinguish)
    private let atlas = SKTextureAtlas(named: "Player")
    private var idleTexture: SKTexture!
    private var walkFrames: [SKTexture] = []
    private var jumpTexture: SKTexture!
    private var deadTexture: SKTexture!

    private var currentAnim = ""

    init() {
        super.init(color: .clear, size: CGSize(width: 32, height: 32))
        name = "player2"
        originalSize = size
        setupTextures()
        setupPhysicsCategories()
        playIdle()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupTextures() {
        func crisp(_ name: String) -> SKTexture {
            let t = atlas.textureNamed(name)
            t.filteringMode = .nearest
            return t
        }

        idleTexture = crisp("idle")
        jumpTexture = crisp("jump")
        deadTexture = crisp("dead")
        walkFrames  = ["walk_01", "walk_02", "walk_03"].map { crisp($0) }

        texture = idleTexture
        // Blue tint to distinguish Player 2 from Player 1
        color = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1)
        colorBlendFactor = 0.5
    }

    private func setupPhysicsCategories() {
        physicsBody?.categoryBitMask    = PhysicsCategory.player2
        physicsBody?.contactTestBitMask = PhysicsCategory.ground   |
                                          PhysicsCategory.enemy    |
                                          PhysicsCategory.lava     |
                                          PhysicsCategory.exit     |
                                          PhysicsCategory.lever
        physicsBody?.collisionBitMask   = PhysicsCategory.ground   |
                                          PhysicsCategory.bridge
    }

    // MARK: - Animations

    func updateAnimation(velocityX: CGFloat) {
        if isDead          { playDead(); return }
        if isInPlatformForm { return }
        if !isGrounded     { playJump(); return }
        if abs(velocityX) > 10 { playWalk() } else { playIdle() }
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

    // MARK: - Toggle platform form

    func toggleForm() {
        guard !isDead else { return }
        isInPlatformForm ? exitPlatformForm() : enterPlatformForm()
    }

    private func enterPlatformForm() {
        isInPlatformForm = true
        disableControls = true
        currentAnim = "platform"
        removeAction(forKey: "anim")

        size = platformSize
        // Solid blue rectangle — no texture in platform form
        texture = nil
        color = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1)
        colorBlendFactor = 1.0

        physicsBody?.isDynamic = false
        physicsBody = SKPhysicsBody(rectangleOf: platformSize)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask    = PhysicsCategory.platform2
        physicsBody?.contactTestBitMask = PhysicsCategory.player1
        physicsBody?.collisionBitMask   = PhysicsCategory.player1  |
                                          PhysicsCategory.ground   |
                                          PhysicsCategory.bridge
    }

    private func exitPlatformForm() {
        isInPlatformForm = false
        disableControls = false
        currentAnim = ""

        size = originalSize
        texture = idleTexture
        color = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1)
        colorBlendFactor = 0.5

        physicsBody = SKPhysicsBody(rectangleOf: originalSize)
        physicsBody?.allowsRotation = false
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0.3
        physicsBody?.friction = 0.7
        physicsBody?.mass = 1.0

        physicsBody?.categoryBitMask    = PhysicsCategory.player2
        physicsBody?.contactTestBitMask = PhysicsCategory.ground   |
                                          PhysicsCategory.enemy    |
                                          PhysicsCategory.lava     |
                                          PhysicsCategory.exit     |
                                          PhysicsCategory.lever
        physicsBody?.collisionBitMask   = PhysicsCategory.ground   |
                                          PhysicsCategory.bridge   |
                                          PhysicsCategory.platform2
    }

    override func die() {
        if isInPlatformForm { exitPlatformForm() }
        super.die()
    }
}
