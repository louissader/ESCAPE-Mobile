import SpriteKit

/// Translates Unity's Lever.cs.
/// When the active player contacts the lever, it toggles and activates its linked bridge.
class LeverNode: SKSpriteNode {

    private(set) var isOn = false
    var onToggle: ((Bool) -> Void)?

    private let leverOff = UIColor(red: 0.6, green: 0.4, blue: 0.1, alpha: 1)
    private let leverOn  = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1)

    private var knob: SKShapeNode!

    // MARK: - Init

    init() {
        super.init(texture: nil, color: UIColor(red: 0.5, green: 0.3, blue: 0.05, alpha: 1),
                   size: CGSize(width: 20, height: 30))
        name = "lever"
        setupPhysics()
        buildVisuals()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 36)) // slightly larger trigger
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask    = PhysicsCategory.lever
        physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        physicsBody?.collisionBitMask   = PhysicsCategory.none
    }

    private func buildVisuals() {
        // Base pole
        let pole = SKShapeNode(rectOf: CGSize(width: 4, height: 20))
        pole.fillColor = UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1)
        pole.strokeColor = .clear
        pole.position = CGPoint(x: 0, y: -5)
        addChild(pole)

        // Knob indicator
        knob = SKShapeNode(circleOfRadius: 6)
        knob.fillColor = leverOff
        knob.strokeColor = .clear
        knob.position = CGPoint(x: -5, y: 8)
        addChild(knob)

        // "!" hint label
        let hint = SKLabelNode(text: "!")
        hint.fontName = "AvenirNext-Bold"
        hint.fontSize = 10
        hint.fontColor = .yellow
        hint.position = CGPoint(x: 0, y: 18)
        addChild(hint)
    }

    // MARK: - Toggle

    func toggle() {
        isOn.toggle()
        let targetX: CGFloat = isOn ? 5 : -5
        let move = SKAction.moveTo(x: targetX, duration: 0.12)
        knob.run(move)
        knob.fillColor = isOn ? leverOn : leverOff
        onToggle?(isOn)
    }
}
