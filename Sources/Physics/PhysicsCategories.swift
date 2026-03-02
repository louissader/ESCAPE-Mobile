import Foundation

struct PhysicsCategory {
    static let none:      UInt32 = 0
    static let player1:   UInt32 = 0x1 << 0  // 1
    static let player2:   UInt32 = 0x1 << 1  // 2
    static let ground:    UInt32 = 0x1 << 2  // 4
    static let fireball:  UInt32 = 0x1 << 3  // 8
    static let enemy:     UInt32 = 0x1 << 4  // 16
    static let lever:     UInt32 = 0x1 << 5  // 32
    static let bridge:    UInt32 = 0x1 << 6  // 64
    static let lava:      UInt32 = 0x1 << 7  // 128
    static let exit:      UInt32 = 0x1 << 8  // 256
    static let platform2: UInt32 = 0x1 << 9  // 512  (Player 2 in platform form)
}
