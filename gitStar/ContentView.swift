//
//  ContentView.swift
//  gitStar
//
//  Created by 茂木史明 on 2026/04/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.gitStarBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    CityStageView()
                        .frame(height: geo.size.height * 0.58)

                    DialogueView(
                        speaker: .of(.master),
                        text: "ようこそ、Git 村へ。\n今日から君に、村の地図を任せよう。"
                    )
                    .frame(height: geo.size.height * 0.42)
                }
            }
        }
    }
}

// MARK: - 上：街UI（仮）
struct CityStageView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.gitStarBackground, .gitStarDeepBlue],
                startPoint: .top,
                endPoint: .bottom
            )

            StarsView()

            VStack(spacing: 12) {
                Spacer()
                Text("GitSTAR")
                    .font(.system(size: 32, weight: .thin, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.9))
                    .tracking(12)
                Text("— 大崩壊の後、記録者たちが歩む村 —")
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.white.opacity(0.35))
                    .tracking(3)
                Spacer()
            }
        }
    }
}

// MARK: - 星空演出
struct StarsView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<40, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.2...0.8)))
                        .frame(width: CGFloat.random(in: 1...2.5))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                }
            }
        }
    }
}

// MARK: - 下：ダイアログ
struct DialogueView: View {
    let speaker: Character
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                CharacterAvatar(character: speaker, size: 40)
                Text(speaker.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(speaker.tint.opacity(0.85))
                    .tracking(2)
                Spacer()
            }

            Text(text)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack {
                Spacer()
                Text("次へ  ›")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.gitStarAccent)
                    .tracking(2)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.gitStarPanel
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.gitStarAccent.opacity(0.3)),
                    alignment: .top
                )
        )
    }
}

// MARK: - カラー定義
extension Color {
    static let gitStarBackground = Color(red: 0.04, green: 0.05, blue: 0.09)
    static let gitStarDeepBlue   = Color(red: 0.06, green: 0.09, blue: 0.16)
    static let gitStarPanel      = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let gitStarAccent     = Color(red: 0.56, green: 0.85, blue: 1.00)
}

#Preview {
    ContentView()
}
