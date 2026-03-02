import SpriteKit

class MenuScene: SKScene {

    private var panelVisible = false

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = UIColor(red: 0.06, green: 0.04, blue: 0.14, alpha: 1)
        buildBackground()
        buildUI()
    }

    private func buildBackground() {
        for _ in 0..<30 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            dot.fillColor = UIColor(white: 1, alpha: CGFloat.random(in: 0.1...0.4))
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat.random(in: -size.width/2...size.width/2),
                                   y: CGFloat.random(in: -size.height/2...size.height/2))
            addChild(dot)
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                y: CGFloat.random(in: 10...40),
                                duration: Double.random(in: 2...5)),
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                y: CGFloat.random(in: -40...(-10)),
                                duration: Double.random(in: 2...5))
            ])
            dot.run(SKAction.repeatForever(float))
        }
    }

    private func buildUI() {
        let title = SKLabelNode(text: "ESCAPE")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 52
        title.fontColor = UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1)
        title.position = CGPoint(x: 0, y: size.height * 0.2)
        title.verticalAlignmentMode = .center
        title.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.03, duration: 0.7),
            SKAction.scale(to: 1.0,  duration: 0.7)
        ])))
        addChild(title)

        let subtitle = SKLabelNode(text: "Co-op Puzzle Platformer")
        subtitle.fontName = "AvenirNext-Regular"; subtitle.fontSize = 14
        subtitle.fontColor = UIColor(white: 0.7, alpha: 1)
        subtitle.position = CGPoint(x: 0, y: size.height * 0.2 - 44)
        subtitle.verticalAlignmentMode = .center
        addChild(subtitle)

        addButton(label: "PLAY",        yOffset: 20,  name: "playBtn",
                  color: UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1))
        addButton(label: "HOW TO PLAY", yOffset: -60, name: "howBtn",
                  color: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1))

        let ver = SKLabelNode(text: "v1.0")
        ver.fontName = "AvenirNext-Regular"; ver.fontSize = 10
        ver.fontColor = UIColor(white: 0.4, alpha: 1)
        ver.position = CGPoint(x: size.width / 2 - 30, y: -size.height / 2 + 20)
        addChild(ver)
    }

    private func addButton(label: String, yOffset: CGFloat, name: String, color: UIColor) {
        let btn = SKSpriteNode(color: color, size: CGSize(width: 200, height: 50))
        btn.position = CGPoint(x: 0, y: yOffset)
        btn.name = name
        let lbl = SKLabelNode(text: label)
        lbl.fontName = "AvenirNext-Bold"; lbl.fontSize = 18
        lbl.fontColor = .white; lbl.verticalAlignmentMode = .center
        btn.addChild(lbl)
        addChild(btn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        // Dismiss how-to panel if visible
        if panelVisible {
            childNode(withName: "panel")?.removeFromParent()
            panelVisible = false
            return
        }

        let hitName = nodes(at: loc).compactMap { $0.name }.first

        if hitName == "playBtn" {
            let scene = LevelSelectScene(size: size)
            scene.scaleMode = scaleMode
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
        } else if hitName == "howBtn" {
            showHowToPlay()
        }
    }

    private func showHowToPlay() {
        panelVisible = true
        let panel = SKSpriteNode(color: UIColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 0.96),
                                 size: CGSize(width: size.width - 40, height: size.height * 0.7))
        panel.position = .zero
        panel.zPosition = 50
        panel.name = "panel"

        let lines: [(String, UIColor, CGFloat)] = [
            ("HOW TO PLAY", .white, 20),
            ("", .white, 14),
            ("◀ ▶   Move active character", UIColor(white: 0.9, alpha: 1), 14),
            ("[A]   Jump  (double-jump works!)", UIColor(white: 0.9, alpha: 1), 14),
            ("[B]   Shooter → Fire fireball", UIColor(red: 1, green: 0.6, blue: 0.2, alpha: 1), 14),
            ("      Shifter → Become platform", UIColor(red: 0.4, green: 0.7, blue: 1, alpha: 1), 14),
            ("[⇄]   Switch between characters", UIColor(red: 0.8, green: 0.8, blue: 1, alpha: 1), 14),
            ("", .white, 14),
            ("— TIPS —", UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1), 14),
            ("★ Collect the star to unlock shooting", UIColor(white: 0.85, alpha: 1), 12),
            ("Use the Shifter as a step for Shooter", UIColor(white: 0.85, alpha: 1), 12),
            ("Touch levers to open bridges", UIColor(white: 0.85, alpha: 1), 12),
            ("", .white, 12),
            ("Tap anywhere to close", UIColor(white: 0.5, alpha: 1), 11),
        ]

        let startY: CGFloat = panel.size.height / 2 - 36
        var y = startY
        for (text, color, size) in lines {
            let lbl = SKLabelNode(text: text)
            lbl.fontName = text.hasPrefix("HOW") || text.hasPrefix("—") ? "AvenirNext-Bold" : "AvenirNext-Regular"
            lbl.fontSize = size
            lbl.fontColor = color
            lbl.horizontalAlignmentMode = .center
            lbl.verticalAlignmentMode = .top
            lbl.position = CGPoint(x: 0, y: y)
            panel.addChild(lbl)
            y -= (size + 6)
        }

        addChild(panel)
    }
}
