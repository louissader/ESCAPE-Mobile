import Foundation

/// Replaces Unity's PlayerPrefs — persists level progress via UserDefaults.
class GameProgressManager {

    static let shared = GameProgressManager()
    private let unlockedCountKey = "unlockedCount"
    static let totalLevels = 3

    private init() {
        if UserDefaults.standard.object(forKey: unlockedCountKey) == nil {
            UserDefaults.standard.set(0, forKey: unlockedCountKey)
        }
    }

    /// How many levels the player has completed (0 = only level 1 unlocked).
    var unlockedCount: Int {
        get { UserDefaults.standard.integer(forKey: unlockedCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: unlockedCountKey) }
    }

    func isLevelUnlocked(_ levelIndex: Int) -> Bool {
        return levelIndex <= unlockedCount
    }

    func unlockNextLevel(after levelIndex: Int) {
        if levelIndex >= unlockedCount {
            unlockedCount = levelIndex + 1
        }
    }

    func resetProgress() {
        unlockedCount = 0
    }
}
