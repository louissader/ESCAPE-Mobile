import CoreGraphics

// MARK: - Data structures

struct PlatformData {
    let position: CGPoint
    let size: CGSize
    var color: PlatformColor = .stone

    enum PlatformColor { case stone, dirt, ice }
}

struct LavaData {
    let position: CGPoint
    let size: CGSize
}

struct LeverData {
    let position: CGPoint
    /// Tag identifying which bridge this lever controls.
    let bridgeTag: String
}

struct BridgeData {
    let position: CGPoint
    let size: CGSize
    let tag: String
    var isHorizontal: Bool = true
}

struct EnemyData {
    let position: CGPoint
    let type: EnemyType

    enum EnemyType { case bat, ghost, skeleton }
}

struct PowerUpData {
    let position: CGPoint
}

struct LevelConfig {
    let platforms: [PlatformData]
    let lavas: [LavaData]
    let levers: [LeverData]
    let bridges: [BridgeData]
    let enemies: [EnemyData]
    let powerUps: [PowerUpData]
    let player1Start: CGPoint
    let player2Start: CGPoint
    let exitPosition: CGPoint
    let cameraScrollLimit: CGSize
    let backgroundColor: (red: Double, green: Double, blue: Double)
}

// MARK: - Level definitions
// Positions are in SpriteKit points (origin center of screen).
// iPhone 14 safe area ~ 390 x 844 pts.

enum LevelLibrary {

    static func level(at index: Int) -> LevelConfig {
        switch index {
        case 0: return level1
        case 1: return level2
        case 2: return level3
        default: return level1
        }
    }

    // ─────────────────────────────────────────────
    // LEVEL 1 — Tutorial: levers, fireballs, bats
    // ─────────────────────────────────────────────
    static let level1 = LevelConfig(
        platforms: [
            // Ground floor
            PlatformData(position: CGPoint(x: 0, y: -300), size: CGSize(width: 800, height: 40)),
            // Mid platforms
            PlatformData(position: CGPoint(x: -100, y: -160), size: CGSize(width: 150, height: 20)),
            PlatformData(position: CGPoint(x: 150, y: -80),  size: CGSize(width: 150, height: 20)),
            PlatformData(position: CGPoint(x: -50, y: 30),   size: CGSize(width: 120, height: 20)),
            // High platform (near exit)
            PlatformData(position: CGPoint(x: 250, y: 160),  size: CGSize(width: 160, height: 20)),
            // Left wall platform
            PlatformData(position: CGPoint(x: -280, y: -160), size: CGSize(width: 40, height: 200)),
            // Right wall platform
            PlatformData(position: CGPoint(x: 320, y: -160), size: CGSize(width: 40, height: 200)),
        ],
        lavas: [
            LavaData(position: CGPoint(x: -280, y: -330), size: CGSize(width: 160, height: 40)),
        ],
        levers: [
            LeverData(position: CGPoint(x: -50, y: 60), bridgeTag: "bridge1"),
        ],
        bridges: [
            BridgeData(position: CGPoint(x: 120, y: 30), size: CGSize(width: 120, height: 18), tag: "bridge1"),
        ],
        enemies: [
            EnemyData(position: CGPoint(x: 100, y: -220), type: .bat),
        ],
        powerUps: [
            PowerUpData(position: CGPoint(x: -100, y: -120)),
        ],
        player1Start: CGPoint(x: -220, y: -250),
        player2Start: CGPoint(x: -180, y: -250),
        exitPosition: CGPoint(x: 260, y: 210),
        cameraScrollLimit: CGSize(width: 800, height: 900),
        backgroundColor: (red: 0.10, green: 0.06, blue: 0.20)
    )

    // ─────────────────────────────────────────────
    // LEVEL 2 — Harder: more enemies, tighter jumps
    // ─────────────────────────────────────────────
    static let level2 = LevelConfig(
        platforms: [
            PlatformData(position: CGPoint(x: 0,    y: -300), size: CGSize(width: 900, height: 40)),
            PlatformData(position: CGPoint(x: -200, y: -180), size: CGSize(width: 120, height: 20)),
            PlatformData(position: CGPoint(x: 0,    y: -100), size: CGSize(width: 120, height: 20)),
            PlatformData(position: CGPoint(x: 200,  y: -20),  size: CGSize(width: 120, height: 20)),
            PlatformData(position: CGPoint(x: 0,    y: 80),   size: CGSize(width: 120, height: 20)),
            PlatformData(position: CGPoint(x: -200, y: 160),  size: CGSize(width: 120, height: 20)),
            PlatformData(position: CGPoint(x: 50,   y: 240),  size: CGSize(width: 200, height: 20)),
        ],
        lavas: [
            LavaData(position: CGPoint(x: -100, y: -330), size: CGSize(width: 200, height: 40)),
            LavaData(position: CGPoint(x: 200,  y: -330), size: CGSize(width: 200, height: 40)),
        ],
        levers: [
            LeverData(position: CGPoint(x: 0, y: 110),    bridgeTag: "bridge2a"),
            LeverData(position: CGPoint(x: -200, y: 190), bridgeTag: "bridge2b"),
        ],
        bridges: [
            BridgeData(position: CGPoint(x: 100, y: 80),  size: CGSize(width: 100, height: 18), tag: "bridge2a"),
            BridgeData(position: CGPoint(x: -80, y: 160), size: CGSize(width: 100, height: 18), tag: "bridge2b"),
        ],
        enemies: [
            EnemyData(position: CGPoint(x: 100, y: -220),  type: .bat),
            EnemyData(position: CGPoint(x: -100, y: -100), type: .bat),
            EnemyData(position: CGPoint(x: 200, y: 50),    type: .ghost),
        ],
        powerUps: [
            PowerUpData(position: CGPoint(x: -200, y: -140)),
        ],
        player1Start: CGPoint(x: -300, y: -250),
        player2Start: CGPoint(x: -260, y: -250),
        exitPosition: CGPoint(x: 60, y: 290),
        cameraScrollLimit: CGSize(width: 900, height: 1100),
        backgroundColor: (red: 0.06, green: 0.10, blue: 0.18)
    )

    // ─────────────────────────────────────────────
    // LEVEL 3 — Final: many enemies, complex layout
    // ─────────────────────────────────────────────
    static let level3 = LevelConfig(
        platforms: [
            PlatformData(position: CGPoint(x: 0,    y: -300), size: CGSize(width: 1000, height: 40)),
            PlatformData(position: CGPoint(x: -300, y: -180), size: CGSize(width: 100,  height: 20)),
            PlatformData(position: CGPoint(x: -100, y: -100), size: CGSize(width: 100,  height: 20)),
            PlatformData(position: CGPoint(x: 100,  y: -20),  size: CGSize(width: 100,  height: 20)),
            PlatformData(position: CGPoint(x: 300,  y: 60),   size: CGSize(width: 100,  height: 20)),
            PlatformData(position: CGPoint(x: 100,  y: 140),  size: CGSize(width: 100,  height: 20)),
            PlatformData(position: CGPoint(x: -100, y: 220),  size: CGSize(width: 100,  height: 20)),
            PlatformData(position: CGPoint(x: 100,  y: 300),  size: CGSize(width: 200,  height: 20)),
        ],
        lavas: [
            LavaData(position: CGPoint(x: -200, y: -330), size: CGSize(width: 200, height: 40)),
            LavaData(position: CGPoint(x: 200,  y: -330), size: CGSize(width: 200, height: 40)),
            LavaData(position: CGPoint(x: 0,    y: -330), size: CGSize(width: 100, height: 40)),
        ],
        levers: [
            LeverData(position: CGPoint(x: 100, y: -50),   bridgeTag: "bridge3a"),
            LeverData(position: CGPoint(x: 300, y: 90),    bridgeTag: "bridge3b"),
            LeverData(position: CGPoint(x: -100, y: 250),  bridgeTag: "bridge3c"),
        ],
        bridges: [
            BridgeData(position: CGPoint(x: 200, y: -20),  size: CGSize(width: 100, height: 18), tag: "bridge3a"),
            BridgeData(position: CGPoint(x: 200, y: 140),  size: CGSize(width: 100, height: 18), tag: "bridge3b"),
            BridgeData(position: CGPoint(x: 0,   y: 300),  size: CGSize(width: 100, height: 18), tag: "bridge3c"),
        ],
        enemies: [
            EnemyData(position: CGPoint(x: 0,    y: -200), type: .bat),
            EnemyData(position: CGPoint(x: 200,  y: -100), type: .bat),
            EnemyData(position: CGPoint(x: -100, y: 50),   type: .ghost),
            EnemyData(position: CGPoint(x: 300,  y: 120),  type: .ghost),
            EnemyData(position: CGPoint(x: 0,    y: 200),  type: .bat),
        ],
        powerUps: [
            PowerUpData(position: CGPoint(x: -300, y: -140)),
        ],
        player1Start: CGPoint(x: -350, y: -250),
        player2Start: CGPoint(x: -310, y: -250),
        exitPosition: CGPoint(x: 110, y: 350),
        cameraScrollLimit: CGSize(width: 1000, height: 1400),
        backgroundColor: (red: 0.12, green: 0.04, blue: 0.08)
    )
}
