//
//  SaveManager.swift
//  gitStar
//

import Foundation

struct SaveData {
    var arcIndex: Int
    var episodeIndex: Int
}

enum SaveManager {
    private static let arcKey     = "gitstar_arc_v1"
    private static let episodeKey = "gitstar_episode_v1"

    static func save(arcIndex: Int, episodeIndex: Int) {
        UserDefaults.standard.set(arcIndex,     forKey: arcKey)
        UserDefaults.standard.set(episodeIndex, forKey: episodeKey)
    }

    static func load() -> SaveData {
        SaveData(
            arcIndex:     UserDefaults.standard.integer(forKey: arcKey),
            episodeIndex: UserDefaults.standard.integer(forKey: episodeKey)
        )
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: arcKey)
        UserDefaults.standard.removeObject(forKey: episodeKey)
    }
}
