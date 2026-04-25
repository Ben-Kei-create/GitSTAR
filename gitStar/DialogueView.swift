//
//  DialogueView.swift
//  gitStar
//

import SwiftUI

struct DialogueView: View {
    let engine: DialogueEngine

    var body: some View {
        ZStack {
            Color.gitStarPanel
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.gitStarAccent.opacity(0.3)),
                    alignment: .top
                )

            if let speaker = engine.currentSpeaker {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        CharacterAvatar(character: speaker, size: 40)
                        Text(speaker.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(speaker.tint.opacity(0.9))
                            .tracking(2)
                        Spacer()
                        Text("\(engine.currentIndex + 1) / \(engine.lines.count)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.2))
                    }

                    Text(engine.displayedText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.white)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 80, alignment: .topLeading)

                    Spacer()

                    HStack {
                        Spacer()
                        if engine.isFinished {
                            Text("おわり")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.3))
                        } else {
                            HStack(spacing: 6) {
                                if engine.isTyping {
                                    Text("スキップ")
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundStyle(.white.opacity(0.4))
                                } else {
                                    Text("次へ")
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color.gitStarAccent)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.gitStarAccent)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { engine.advance() }
    }
}
