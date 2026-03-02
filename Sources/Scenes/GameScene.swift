import SpriteKit

// MARK: - Game state enum
enum SceneGameState {
    case playing, gameOver, levelComplete, gameComplete
}

// MARK: - GameScene

/// Main gameplay scene.  Translates Unity's GameState.cs + level scenes into one SpriteKit scene.
class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties

    var levelIndex: Int = 0

    private var player1: Player1Node!
    private var player2: Player2Node!

    /// Which player the virtual controls currently drive.
    private var activePlayer: Int = 1

    private var hud: GameHUD!
    private var controls: TouchControlsNode!
    private var cameraNode: SKCameraNode!

    private var state: SceneGameState = .playing

    // Lever → Bridge lookup (by tag)
    private var bridges: [String: BridgeNode] = [:]

    // Timing
    private var lastTime: TimeInterval = 0
    private var currentTime: TimeInterval = 0

    // Overlay for fade-in/out transitions
    private var overlay: SKSpriteNode!

    // MARK: - Scene lifecycle

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupPhysics()
        buildLevel()
        buildCamera()
        buildHUD()
        buildControls()
        fadeIn()
    }

    // MARK: - Physics world

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        physicsWorld.contactDelegate = self
    }

    // MARK: - Level building

    private func buildLevel() {
        let config = LevelLibrary.level(at: levelIndex)
        backgroundColor = UIColor(red: config.backgroundColor.red,
                                  green: config.backgroundColor.green,
                                  blue: config.backgroundColor.blue,
                                  alpha: 1)

        // Platforms
        for p in config.platforms { addPlatform(p) }

        // Lava
        for l in config.lavas { addLava(l) }

        // Bridges (created before levers so levers can reference them)
        for b in config.bridges {
            let node = BridgeNode(size: b.size, tag: b.tag)
            node.position = b.position
            bridges[b.tag] = node
            addChild(node)
        }

        // Levers
        for l in config.levers { addLever(l) }

        // Enemies
        for e in config.enemies { addEnemy(e) }

        // Power-ups
        for pu in config.powerUps { addPowerUp(pu) }

        // Exit
        addExit(at: config.exitPosition)

        // Players
        player1 = Player1Node()
        player1.position = config.player1Start
        player1.setSpawnPosition(config.player1Start)
        player1.gameScene = self
        addChild(player1)

        player2 = Player2Node()
        player2.position = config.player2Start
        player2.setSpawnPosition(config.player2Start)
        addChild(player2)

        // Dim the inactive player slightly
        player2.alpha = 0.6
    }

    // MARK: – Node factories

    private func addPlatform(_ data: PlatformData) {
        let node = SKSpriteNode(color: UIColor(red: 0.35, green: 0.25, blue: 0.15, alpha: 1),
                                size: data.size)
        node.position = data.position
        node.name = "ground"

        node.physicsBody = SKPhysicsBody(rectangleOf: data.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0.7
        node.physicsBody?.categoryBitMask    = PhysicsCategory.ground
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        node.physicsBody?.collisionBitMask   = PhysicsCategory.player1 | PhysicsCategory.player2 | PhysicsCategory.platform2

        // Surface highlight
        let highlight = SKSpriteNode(color: UIColor(red: 0.5, green: 0.38, blue: 0.22, alpha: 1),
                                     size: CGSize(width: data.size.width, height: 4))
        highlight.position = CGPoint(x: 0, y: data.size.height / 2 - 2)
        node.addChild(highlight)

        addChild(node)
    }

    private func addLava(_ data: LavaData) {
        let node = SKSpriteNode(color: UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1),
                                size: data.size)
        node.position = data.position
        node.name = "lava"

        node.physicsBody = SKPhysicsBody(rectangleOf: data.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask    = PhysicsCategory.lava
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        node.physicsBody?.collisionBitMask   = PhysicsCategory.none

        // Glow effect
        let glow = SKShapeNode(rectOf: data.size)
        glow.fillColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 0.3)
        glow.strokeColor = .clear
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.1, duration: 0.5),
            SKAction.fadeAlpha(to: 0.4, duration: 0.5)
        ])
        glow.run(SKAction.repeatForever(pulse))
        node.addChild(glow)

        addChild(node)
    }

    private func addLever(_ data: LeverData) {
        let node = LeverNode()
        node.position = data.position
        node.onToggle = { [weak self] isOn in
            self?.bridges[data.bridgeTag]?.setActive(isOn)
        }
        addChild(node)
    }

    private func addEnemy(_ data: EnemyData) {
        switch data.type {
        case .bat:
            let bat = BatNode()
            bat.activate(at: data.position, in: self)
            addChild(bat)
        case .ghost:
            addGhost(at: data.position)
        case .skeleton:
            break // Future implementation
        }
    }

    private func addGhost(at position: CGPoint) {
        let ghost = SKSpriteNode(color: UIColor(white: 0.85, alpha: 0.7),
                                 size: CGSize(width: 22, height: 28))
        ghost.position = position
        ghost.name = "ghost"
        ghost.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 22, height: 28))
        ghost.physicsBody?.isDynamic = false
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        ghost.physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2 | PhysicsCategory.fireball
        ghost.physicsBody?.collisionBitMask   = PhysicsCategory.none

        // Float up/down
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 0.8),
            SKAction.moveBy(x: 0, y: -15, duration: 0.8)
        ])
        ghost.run(SKAction.repeatForever(float))
        addChild(ghost)
    }

    private func addPowerUp(at data: PowerUpData) {
        let star = SKShapeNode(circleOfRadius: 10)
        star.fillColor = .yellow
        star.strokeColor = .orange
        star.lineWidth = 2
        star.position = data.position
        star.name = "powerup"
        star.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        star.physicsBody?.isDynamic = false
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.categoryBitMask    = PhysicsCategory.none
        star.physicsBody?.contactTestBitMask = PhysicsCategory.player1

        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)
        star.run(SKAction.repeatForever(spin))
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.5),
            SKAction.moveBy(x: 0, y: -6, duration: 0.5)
        ])
        star.run(SKAction.repeatForever(bob))
        addChild(star)
    }

    private func addPowerUp(_ data: PowerUpData) {
        addPowerUp(at: data)
    }

    private func addExit(at position: CGPoint) {
        let exitSize = CGSize(width: 36, height: 50)
        let door = SKSpriteNode(color: UIColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 1),
                                size: exitSize)
        door.position = position
        door.name = "exit"

        door.physicsBody = SKPhysicsBody(rectangleOf: exitSize)
        door.physicsBody?.isDynamic = false
        door.physicsBody?.categoryBitMask    = PhysicsCategory.exit
        door.physicsBody?.contactTestBitMask = PhysicsCategory.player1 | PhysicsCategory.player2
        door.physicsBody?.collisionBitMask   = PhysicsCategory.none

        // Pulsing arrow
        let arrow = SKLabelNode(text: "▲")
        arrow.fontSize = 14; arrow.fontColor = .white
        arrow.position = CGPoint(x: 0, y: 20)
        let pulse = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.4),
            SKAction.moveBy(x: 0, y: -5, duration: 0.4)
        ])
        arrow.run(SKAction.repeatForever(pulse))
        door.addChild(arrow)

        let exitLabel = SKLabelNode(text: "EXIT")
        exitLabel.fontName = "AvenirNext-Bold"; exitLabel.fontSize = 9
        exitLabel.fontColor = .white
        exitLabel.position = CGPoint(x: 0, y: -14)
        door.addChild(exitLabel)

        addChild(door)
    }

    // MARK: - Camera

    private func buildCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }

    // MARK: - HUD

    private func buildHUD() {
        hud = GameHUD()
        hud.build(for: size, levelIndex: levelIndex)
        cameraNode.addChild(hud)
    }

    // MARK: - Controls

    private func buildControls() {
        controls = TouchControlsNode()
        controls.build(for: size)
        controls.zPosition = 150
        cameraNode.addChild(controls)
    }

    // MARK: - Fade in

    private func fadeIn() {
        overlay = SKSpriteNode(color: .black, size: size)
        overlay.zPosition = 300
        cameraNode.addChild(overlay)
        overlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.6),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        guard state == .playing else { return }
        let delta = lastTime == 0 ? 0 : min(currentTime - lastTime, 0.05)
        lastTime = currentTime
        self.currentTime = currentTime

        processInput()
        updatePlayers(delta: delta)
        updateCamera()
        updateHUD()
        checkBothPlayersDead()
    }

    private func processInput() {
        let inp = controls.consumeInput()

        // Switch active player
        if inp.switchTapped { switchActive() }

        // Move & jump the active player
        let active = activePlayer == 1 ? player1 as PlayerNode : player2 as PlayerNode
        active.move(direction: inp.horizontal)

        if inp.jumpTapped { active.jump() }

        // Action
        if inp.actionTapped {
            if activePlayer == 1 {
                player1.tryShoot(currentTime: currentTime)
            } else {
                player2.toggleForm()
            }
        }

        // Inactive player stands still
        let inactive = activePlayer == 1 ? player2 as PlayerNode : player1 as PlayerNode
        if !inactive.disableControls {
            inactive.move(direction: 0)
        }
    }

    private func updatePlayers(delta: TimeInterval) {
        player1.update(deltaTime: delta)
        player2.update(deltaTime: delta)
    }

    private func updateCamera() {
        let active = activePlayer == 1 ? player1.position : player2.position
        let passive = activePlayer == 1 ? player2.position : player1.position

        // Follow midpoint between active player and passive (keep both in view)
        let mid = CGPoint(x: (active.x + passive.x) / 2,
                          y: (active.y + passive.y) / 2)

        let lerpFactor: CGFloat = 0.08
        let cx = cameraNode.position.x + (mid.x - cameraNode.position.x) * lerpFactor
        let cy = cameraNode.position.y + (mid.y - cameraNode.position.y) * lerpFactor
        cameraNode.position = CGPoint(x: cx, y: cy)
    }

    private func updateHUD() {
        hud.update(p1HP: player1.hp, p1MaxHP: player1.maxHP,
                   p2HP: player2.hp, p2MaxHP: player2.maxHP,
                   activePlayer: activePlayer)
    }

    private func checkBothPlayersDead() {
        if player1.isDead && player2.isDead { triggerGameOver() }
    }

    // MARK: - Character switching

    private func switchActive() {
        guard state == .playing else { return }
        activePlayer = activePlayer == 1 ? 2 : 1
        player1.alpha = activePlayer == 1 ? 1.0 : 0.6
        player2.alpha = activePlayer == 2 ? 1.0 : 0.6

        // Brief pulse on newly active player
        let active = activePlayer == 1 ? player1 as SKNode : player2 as SKNode
        active.run(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ]))
    }

    // MARK: - Game events

    func triggerGameOver() {
        guard state == .playing else { return }
        state = .gameOver
        showFullScreenOverlay(text: "GAME OVER", color: UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.85)) {
            self.loadLevelSelect()
        }
    }

    private func triggerLevelComplete() {
        guard state == .playing else { return }
        state = .levelComplete
        GameProgressManager.shared.unlockNextLevel(after: levelIndex)

        let isLast = levelIndex >= GameProgressManager.totalLevels - 1
        if isLast {
            showFullScreenOverlay(text: "YOU ESCAPED!", color: UIColor(red: 0.1, green: 0.6, blue: 0.2, alpha: 0.9)) {
                self.loadMainMenu()
            }
        } else {
            showFullScreenOverlay(text: "LEVEL COMPLETE!", color: UIColor(red: 0.1, green: 0.5, blue: 0.8, alpha: 0.85)) {
                self.loadNextLevel()
            }
        }
    }

    private func showFullScreenOverlay(text: String, color: UIColor, completion: @escaping () -> Void) {
        let bg = SKSpriteNode(color: color, size: size)
        bg.zPosition = 250
        cameraNode.addChild(bg)
        bg.alpha = 0

        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"; label.fontSize = 36
        label.fontColor = .white; label.verticalAlignmentMode = .center
        label.zPosition = 1
        bg.addChild(label)

        let sub = SKLabelNode(text: "Tap to continue")
        sub.fontName = "AvenirNext-Regular"; sub.fontSize = 16
        sub.fontColor = UIColor(white: 0.9, alpha: 1); sub.verticalAlignmentMode = .center
        sub.position = CGPoint(x: 0, y: -50); sub.zPosition = 1
        bg.addChild(sub)

        bg.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 1.5),
            SKAction.run { completion() }
        ]))
    }

    // MARK: - Scene transitions

    private func loadNextLevel() {
        let next = GameScene()
        next.levelIndex = levelIndex + 1
        next.size = size
        next.scaleMode = scaleMode
        view?.presentScene(next, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func loadLevelSelect() {
        let scene = LevelSelectScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func loadMainMenu() {
        let scene = MenuScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.7))
    }

    // MARK: - Physics contact delegate

    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        let combined = maskA | maskB

        // Ground contact — update grounding counter
        if combined == (PhysicsCategory.player1 | PhysicsCategory.ground) ||
           combined == (PhysicsCategory.player1 | PhysicsCategory.bridge) ||
           combined == (PhysicsCategory.player1 | PhysicsCategory.platform2) {
            player1.groundContactCount += 1
        }
        if combined == (PhysicsCategory.player2 | PhysicsCategory.ground) ||
           combined == (PhysicsCategory.player2 | PhysicsCategory.bridge) {
            player2.groundContactCount += 1
        }

        // Lava — instant kill
        if combined & PhysicsCategory.lava != 0 {
            if combined & PhysicsCategory.player1 != 0 { player1.die() }
            if combined & PhysicsCategory.player2 != 0 { player2.die() }
        }

        // Enemy hits player
        if combined & PhysicsCategory.enemy != 0 {
            if combined & PhysicsCategory.player1 != 0 {
                player1.takeDamage(30, currentTime: currentTime)
            }
            if combined & PhysicsCategory.player2 != 0 {
                player2.takeDamage(30, currentTime: currentTime)
            }
        }

        // Player fireball hits enemy
        if maskA == PhysicsCategory.fireball || maskB == PhysicsCategory.fireball {
            let fireballBody = maskA == PhysicsCategory.fireball ? contact.bodyA : contact.bodyB
            let otherBody    = maskA == PhysicsCategory.fireball ? contact.bodyB : contact.bodyA

            if let fireball = fireballBody.node as? FireballNode, fireball.firedByPlayer {
                if let enemy = otherBody.node as? BatNode {
                    enemy.destroy()
                    fireball.hit()
                } else if let ghost = otherBody.node, ghost.name == "ghost" {
                    ghost.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.15),
                        SKAction.removeFromParent()
                    ]))
                    fireball.hit()
                }
            }

            // Enemy fireball hits player
            if let fireball = fireballBody.node as? FireballNode, !fireball.firedByPlayer {
                if otherBody.categoryBitMask == PhysicsCategory.player1 {
                    player1.takeDamage(20, currentTime: currentTime)
                } else if otherBody.categoryBitMask == PhysicsCategory.player2 {
                    player2.takeDamage(20, currentTime: currentTime)
                }
                fireball.hit()
            }
        }

        // Lever contact — toggle
        if combined & PhysicsCategory.lever != 0 {
            let leverBody = maskA == PhysicsCategory.lever ? contact.bodyA : contact.bodyB
            (leverBody.node as? LeverNode)?.toggle()
        }

        // Exit — level complete (BOTH players must be near exit, OR active player)
        if combined & PhysicsCategory.exit != 0 {
            if combined & PhysicsCategory.player1 != 0 || combined & PhysicsCategory.player2 != 0 {
                triggerLevelComplete()
            }
        }

        // Power-up collected by Player 1
        if combined & PhysicsCategory.player1 != 0 {
            let other = maskA == PhysicsCategory.player1 ? contact.bodyB.node : contact.bodyA.node
            if other?.name == "powerup" {
                player1.collectPowerUp()
                other?.removeFromParent()
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        let combined = maskA | maskB

        if combined == (PhysicsCategory.player1 | PhysicsCategory.ground) ||
           combined == (PhysicsCategory.player1 | PhysicsCategory.bridge) ||
           combined == (PhysicsCategory.player1 | PhysicsCategory.platform2) {
            player1.groundContactCount = max(0, player1.groundContactCount - 1)
        }
        if combined == (PhysicsCategory.player2 | PhysicsCategory.ground) ||
           combined == (PhysicsCategory.player2 | PhysicsCategory.bridge) {
            player2.groundContactCount = max(0, player2.groundContactCount - 1)
        }
    }
}
