import SpriteKit

/// On-screen virtual controls.
/// Layout:
///   Left side  — D-pad (left/right arrows + jump-up)
///   Right side — [Action] button (shoot / transform)  +  [Jump] button
///   Center-top — [Switch] character button
struct ControlInput {
    var horizontal: CGFloat = 0   // -1, 0, or 1
    var jumpTapped: Bool = false
    var actionTapped: Bool = false
    var switchTapped: Bool = false
}

class TouchControlsNode: SKNode {

    // Exposed input — read once per frame in GameScene.update()
    private(set) var input = ControlInput()

    // Button nodes
    private var leftBtn: SKSpriteNode!
    private var rightBtn: SKSpriteNode!
    private var jumpBtn: SKSpriteNode!
    private var actionBtn: SKSpriteNode!
    private var switchBtn: SKSpriteNode!

    // Track which touch drives which button
    private var touchMap: [UITouch: String] = [:]

    // One-shot flags cleared after being read
    private var jumpPending   = false
    private var actionPending = false
    private var switchPending = false

    // MARK: - Build UI

    func build(for size: CGSize) {
        let safe: CGFloat = 40          // margin from screen edge
        let btnSize = CGSize(width: 60, height: 60)
        let bottomY = -size.height / 2 + safe + btnSize.height / 2

        // ── D-pad ──────────────────────────────────────
        let dpadX = -size.width / 2 + safe

        leftBtn  = makeButton(label: "◀", color: .dpad, at: CGPoint(x: dpadX, y: bottomY))
        rightBtn = makeButton(label: "▶", color: .dpad, at: CGPoint(x: dpadX + btnSize.width + 12, y: bottomY))

        // ── Action & Jump (right side) ─────────────────
        let rightX = size.width / 2 - safe - btnSize.width / 2
        jumpBtn   = makeButton(label: "A", color: .jump,   at: CGPoint(x: rightX, y: bottomY))
        actionBtn = makeButton(label: "B", color: .action, at: CGPoint(x: rightX - btnSize.width - 12, y: bottomY))

        // ── Switch character (center top) ──────────────
        switchBtn = makeButton(label: "⇄", color: .switch_, at: CGPoint(x: 0, y: size.height / 2 - 60),
                               size: CGSize(width: 80, height: 36))
        switchBtn.alpha = 0.75

        [leftBtn, rightBtn, jumpBtn, actionBtn, switchBtn].forEach { addChild($0) }

        isUserInteractionEnabled = true
    }

    private func makeButton(label: String, color: ButtonColor,
                            at pos: CGPoint,
                            size: CGSize = CGSize(width: 60, height: 60)) -> SKSpriteNode {
        let bg = SKSpriteNode(color: color.uiColor, size: size)
        bg.position = pos
        bg.alpha = 0.55
        bg.zPosition = 100

        let lbl = SKLabelNode(text: label)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = color == .switch_ ? 16 : 22
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        bg.addChild(lbl)

        return bg
    }

    private enum ButtonColor {
        case dpad, jump, action, switch_

        var uiColor: UIColor {
            switch self {
            case .dpad:    return UIColor(white: 1, alpha: 0.3)
            case .jump:    return UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 0.8)
            case .action:  return UIColor(red: 0.8, green: 0.3, blue: 0.1, alpha: 0.8)
            case .switch_: return UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 0.9)
            }
        }
    }

    // MARK: - Read input (called each frame)

    func consumeInput() -> ControlInput {
        var out = input
        out.jumpTapped   = jumpPending;   jumpPending   = false
        out.actionTapped = actionPending; actionPending = false
        out.switchTapped = switchPending; switchPending = false
        return out
    }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if leftBtn.contains(loc)   { touchMap[touch] = "left";   updateHorizontal() }
            else if rightBtn.contains(loc) { touchMap[touch] = "right";  updateHorizontal() }
            else if jumpBtn.contains(loc)  { touchMap[touch] = "jump";   jumpPending = true }
            else if actionBtn.contains(loc){ touchMap[touch] = "action"; actionPending = true }
            else if switchBtn.contains(loc){ touchMap[touch] = "switch"; switchPending = true }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchMap.removeValue(forKey: touch)
        }
        updateHorizontal()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func updateHorizontal() {
        let held = Set(touchMap.values)
        if held.contains("left") && !held.contains("right") {
            input.horizontal = -1
        } else if held.contains("right") && !held.contains("left") {
            input.horizontal = 1
        } else {
            input.horizontal = 0
        }
    }
}
