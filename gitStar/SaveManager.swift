//
//  SaveManager.swift
//  gitStar
//

import Foundation

struct SaveData {
    var episodeIndex: Int
}

enum SaveManager {
    private static let key = "gitstar_save_v1"

    static func save(episodeIndex: Int) {
        UserDefaults.standard.set(episodeIndex, forKey: key)
    }

    static func load() -> SaveData {
        let index = UserDefaults.standard.integer(forKey: key)
        return SaveData(episodeIndex: index)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
