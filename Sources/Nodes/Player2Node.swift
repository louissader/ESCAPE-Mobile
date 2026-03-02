import SpriteKit

/// Player 2 — The Shape-Shifter.
/// Translates Unity's PlayerCharacterTwo: same movement as P1 plus a transform ability
/// that turns P2 into a solid static platform so P1 can walk on top.
class Player2Node: PlayerNode {

    // MARK: - Transformation state
    private(set) var isInPlatformForm = false
    private var originalSize: CGSize = .zero
    private let platformSize = CGSize(width: 80, height: 18)

    // MARK: - Init

    init() {
        super.init(color: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1), // blue
                   size: CGSize(width: 28, height: 38))
        name = "player2"
        originalSize = size
        setupPhysicsCategories()
        addFace()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

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

    private func addFace() {
        let eyeL = SKShapeNode(circleOfRadius: 3)
        eyeL.fillColor = .white; eyeL.strokeColor = .clear
        eyeL.position = CGPoint(x: -6, y: 8)
        addChild(eyeL)

        let eyeR = SKShapeNode(circleOfRadius: 3)
        eyeR.fillColor = .white; eyeR.strokeColor = .clear
        eyeR.position = CGPoint(x: 6, y: 8)
        addChild(eyeR)
    }

    // MARK: - Toggle platform form

    func toggleForm() {
        guard !isDead else { return }

        if isInPlatformForm {
            exitPlatformForm()
        } else {
            enterPlatformForm()
        }
    }

    private func enterPlatformForm() {
        isInPlatformForm = true
        disableControls = true

        // Resize to a wide flat rectangle
        size = platformSize
        color = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1)

        // Make physics body static so P1 can stand on it
        physicsBody?.isDynamic = false
        physicsBody = SKPhysicsBody(rectangleOf: platformSize)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask    = PhysicsCategory.platform2
        physicsBody?.contactTestBitMask = PhysicsCategory.player1
        physicsBody?.collisionBitMask   = PhysicsCategory.player1  |
                                          PhysicsCategory.ground   |
                                          PhysicsCategory.bridge

        // Visual label
        let label = SKLabelNode(text: "PLATFORM")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 8
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "platformLabel"
        addChild(label)
    }

    private func exitPlatformForm() {
        isInPlatformForm = false
        disableControls = false

        // Restore character size & physics
        size = originalSize
        color = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)

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

        childNode(withName: "platformLabel")?.removeFromParent()
    }

    // MARK: - Override die to exit platform form first

    override func die() {
        if isInPlatformForm { exitPlatformForm() }
        super.die()
    }
}
