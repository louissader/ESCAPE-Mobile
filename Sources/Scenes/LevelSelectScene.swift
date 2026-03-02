import SpriteKit

class LevelSelectScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.06, green: 0.04, blue: 0.14, alpha: 1)
        buildUI()
    }

    private func buildUI() {
        // Title
        let title = SKLabelNode(text: "SELECT LEVEL")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: size.height * 0.3)
        title.verticalAlignmentMode = .center
        addChild(title)

        let progress = GameProgressManager.shared
        let levelNames = ["Grotto", "Dungeon", "The Vault"]

        let spacing: CGFloat = 90
        for i in 0..<GameProgressManager.totalLevels {
            let yPos = CGFloat(0) - CGFloat(i) * spacing
            let unlocked = progress.isLevelUnlocked(i)
            addLevelButton(index: i, name: levelNames[i], y: yPos, unlocked: unlocked)
        }

        // Back button
        let back = SKSpriteNode(color: UIColor(white: 0.3, alpha: 0.8),
                                size: CGSize(width: 120, height: 40))
        back.position = CGPoint(x: 0, y: -size.height * 0.38)
        back.name = "backBtn"
        let backLbl = SKLabelNode(text: "◀  BACK")
        backLbl.fontName = "AvenirNext-Bold"; backLbl.fontSize = 15
        backLbl.fontColor = .white; backLbl.verticalAlignmentMode = .center
        back.addChild(backLbl)
        addChild(back)
    }

    private func addLevelButton(index: Int, name: String, y: CGFloat, unlocked: Bool) {
        let color = unlocked
            ? UIColor(red: 0.15, green: 0.45, blue: 0.75, alpha: 1)
            : UIColor(white: 0.2, alpha: 0.8)

        let btn = SKSpriteNode(color: color, size: CGSize(width: 240, height: 66))
        btn.position = CGPoint(x: 0, y: y)
        btn.name = unlocked ? "level_\(index)" : "locked"

        let numLbl = SKLabelNode(text: "\(index + 1)")
        numLbl.fontName = "AvenirNext-Heavy"; numLbl.fontSize = 30
        numLbl.fontColor = unlocked ? .white : UIColor(white: 0.5, alpha: 1)
        numLbl.horizontalAlignmentMode = .left
        numLbl.verticalAlignmentMode = .center
        numLbl.position = CGPoint(x: -105, y: 0)
        btn.addChild(numLbl)

        let nameLbl = SKLabelNode(text: name)
        nameLbl.fontName = "AvenirNext-Bold"; nameLbl.fontSize = 18
        nameLbl.fontColor = unlocked ? .white : UIColor(white: 0.5, alpha: 1)
        nameLbl.horizontalAlignmentMode = .left
        nameLbl.verticalAlignmentMode = .center
        nameLbl.position = CGPoint(x: -60, y: 6)
        btn.addChild(nameLbl)

        let statusLbl = SKLabelNode(text: unlocked ? "▶" : "🔒")
        statusLbl.fontSize = unlocked ? 20 : 16
        statusLbl.fontColor = unlocked ? UIColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 1) : UIColor(white: 0.4, alpha: 1)
        statusLbl.horizontalAlignmentMode = .right
        statusLbl.verticalAlignmentMode = .center
        statusLbl.position = CGPoint(x: 100, y: 0)
        btn.addChild(statusLbl)

        addChild(btn)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hitName = nodes(at: loc).compactMap { $0.name }.first ?? ""

        if hitName == "backBtn" {
            let scene = MenuScene(size: size)
            scene.scaleMode = scaleMode
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
            return
        }

        if hitName.hasPrefix("level_"), let indexStr = hitName.split(separator: "_").last,
           let index = Int(indexStr) {
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            scene.levelIndex = index
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
        }
    }
}
