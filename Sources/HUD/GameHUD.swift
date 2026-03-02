import SpriteKit

/// Heads-up display attached to the camera (always visible).
class GameHUD: SKNode {

    private var p1HPBar: SKSpriteNode!
    private var p1HPFill: SKSpriteNode!
    private var p2HPBar: SKSpriteNode!
    private var p2HPFill: SKSpriteNode!
    private var activeLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!

    let barWidth: CGFloat = 100
    let barHeight: CGFloat = 10

    func build(for size: CGSize, levelIndex: Int) {
        let top = size.height / 2 - 30
        let left = -size.width / 2 + 20

        // ── Player 1 HP ─────────────────────────────────
        let p1Label = SKLabelNode(text: "P1")
        p1Label.fontName = "AvenirNext-Bold"; p1Label.fontSize = 11
        p1Label.fontColor = UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1)
        p1Label.horizontalAlignmentMode = .left
        p1Label.position = CGPoint(x: left, y: top)
        addChild(p1Label)

        p1HPBar = makeBar(width: barWidth, height: barHeight, bg: UIColor(white: 0.2, alpha: 0.8))
        p1HPBar.position = CGPoint(x: left + barWidth / 2 + 24, y: top + 3)
        addChild(p1HPBar)

        p1HPFill = makeBar(width: barWidth, height: barHeight - 2,
                           bg: UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1))
        p1HPFill.position = .zero
        p1HPFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        p1HPFill.position = CGPoint(x: -barWidth / 2 + 1, y: 0)
        p1HPBar.addChild(p1HPFill)

        // ── Player 2 HP ─────────────────────────────────
        let p2Label = SKLabelNode(text: "P2")
        p2Label.fontName = "AvenirNext-Bold"; p2Label.fontSize = 11
        p2Label.fontColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)
        p2Label.horizontalAlignmentMode = .left
        p2Label.position = CGPoint(x: left, y: top - 20)
        addChild(p2Label)

        p2HPBar = makeBar(width: barWidth, height: barHeight, bg: UIColor(white: 0.2, alpha: 0.8))
        p2HPBar.position = CGPoint(x: left + barWidth / 2 + 24, y: top - 20 + 3)
        addChild(p2HPBar)

        p2HPFill = makeBar(width: barWidth, height: barHeight - 2,
                           bg: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1))
        p2HPFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        p2HPFill.position = CGPoint(x: -barWidth / 2 + 1, y: 0)
        p2HPBar.addChild(p2HPFill)

        // ── Active player indicator ──────────────────────
        activeLabel = SKLabelNode(text: "▶ SHOOTER active")
        activeLabel.fontName = "AvenirNext-Bold"; activeLabel.fontSize = 10
        activeLabel.fontColor = .white
        activeLabel.position = CGPoint(x: 0, y: top)
        addChild(activeLabel)

        // ── Level label ──────────────────────────────────
        levelLabel = SKLabelNode(text: "LEVEL \(levelIndex + 1)")
        levelLabel.fontName = "AvenirNext-Heavy"; levelLabel.fontSize = 12
        levelLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.position = CGPoint(x: size.width / 2 - 16, y: top)
        addChild(levelLabel)

        zPosition = 200
    }

    private func makeBar(width: CGFloat, height: CGFloat, bg: UIColor) -> SKSpriteNode {
        let bar = SKSpriteNode(color: bg, size: CGSize(width: width, height: height))
        return bar
    }

    // MARK: - Update

    func update(p1HP: CGFloat, p1MaxHP: CGFloat,
                p2HP: CGFloat, p2MaxHP: CGFloat,
                activePlayer: Int) {
        let p1Pct = max(0, p1HP / p1MaxHP)
        let p2Pct = max(0, p2HP / p2MaxHP)

        p1HPFill.xScale = p1Pct
        p2HPFill.xScale = p2Pct

        // Colour danger
        p1HPFill.color = p1Pct < 0.3
            ? UIColor(red: 1, green: 0.1, blue: 0.1, alpha: 1)
            : UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1)

        p2HPFill.color = p2Pct < 0.3
            ? UIColor(red: 1, green: 0.1, blue: 0.1, alpha: 1)
            : UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)

        if activePlayer == 1 {
            activeLabel.text = "▶ SHOOTER active"
            activeLabel.fontColor = UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1)
        } else {
            activeLabel.text = "▶ SHAPE-SHIFTER active"
            activeLabel.fontColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)
        }
    }
}
