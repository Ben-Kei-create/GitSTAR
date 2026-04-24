//
//  DialogueEngine.swift
//  gitStar
//

import SwiftUI

struct DialogueLine: Identifiable {
    let id = UUID()
    let speaker: CharacterID
    let text: String
}

@MainActor
@Observable
class DialogueEngine {
    var lines: [DialogueLine] = []
    var currentIndex: Int = 0
    var displayedText: String = ""
    var isTyping: Bool = false
    var isFinished: Bool = false

    private var typingTask: Task<Void, Never>?

    var currentLine: DialogueLine? {
        guard currentIndex < lines.count else { return nil }
        return lines[currentIndex]
    }

    var currentSpeaker: Character? {
        guard let line = currentLine else { return nil }
        return Character.of(line.speaker)
    }

    func load(_ lines: [DialogueLine]) {
        self.lines = lines
        currentIndex = 0
        isFinished = false
        startTyping()
    }

    func advance() {
        if isTyping {
            // タイプ中はスキップして全文表示
            typingTask?.cancel()
            displayedText = currentLine?.text ?? ""
            isTyping = false
        } else {
            // 次のセリフへ
            if currentIndex + 1 < lines.count {
                currentIndex += 1
                startTyping()
            } else {
                isFinished = true
            }
        }
    }

    private func startTyping() {
        guard let line = currentLine else { return }
        displayedText = ""
        isTyping = true

        typingTask = Task {
            for char in line.text {
                if Task.isCancelled { break }
                displayedText.append(char)
                let delay: UInt64 = char == "\n" ? 120_000_000 : 38_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
            isTyping = false
        }
    }
}
