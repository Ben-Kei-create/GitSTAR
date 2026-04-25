//
//  ArcCompleteView.swift
//  gitStar
//

import SwiftUI

struct ArcCompleteView: View {
    let arc: Arc
    let onNext: () -> Void

    @State private var appeared = false
    @State private var starsExplode = false
    @State private var commandsVisible = false
    @State private var buttonVisible = false

    var body: some View {
        ZStack {
            Color.gitStarBackground.ignoresSafeArea()
            StarsView()
            confettiLayer

            VStack(spacing: 32) {
                Spacer()

                // Arc バッジ
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.gitStarAccent.opacity(0.08))
                            .frame(width: 90, height: 90)
                            .scaleEffect(appeared ? 1.0 : 0.4)
                        Circle()
                            .stroke(Color.gitStarAccent.opacity(0.4), lineWidth: 1)
                            .frame(width: 90, height: 90)
                        Text("Arc\n\(arc.number)")
                            .font(.system(size: 18, weight: .thin, design: .monospaced))
                            .foregroundStyle(Color.gitStarAccent)
                            .multilineTextAlignment(.center)
                            .tracking(2)
                    }
                    .animation(.spring(duration: 0.7, bounce: 0.4).delay(0.1), value: appeared)

                    Text("COMPLETE")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.gitStarAccent)
                        .tracking(8)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)
                }

                // タイトル
                VStack(spacing: 8) {
                    Text(arc.title)
                        .font(.system(size: 26, weight: .thin))
                        .foregroundStyle(.white)
                        .tracking(4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.7).delay(0.5), value: appeared)

                    Text(arc.subtitle)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(3)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.7), value: appeared)
                }

                // 習得コマンド一覧
                VStack(alignment: .leading, spacing: 10) {
                    Text("習得したコマンド")
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(.white.opacity(0.35))
                        .tracking(3)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Array(arc.commands.enumerated()), id: \.offset) { i, cmd in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.gitStarAccent)
                                Text(cmd)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.8))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .opacity(commandsVisible ? 1 : 0)
                            .offset(y: commandsVisible ? 0 : 10)
                            .animation(.easeOut(duration: 0.4).delay(0.9 + Double(i) * 0.08), value: commandsVisible)
                        }
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // 次へボタン
                Button(action: onNext) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                        Text("次のArcへ")
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .tracking(3)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(Color.gitStarBackground)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.gitStarAccent)
                            .shadow(color: Color.gitStarAccent.opacity(0.5), radius: 16)
                    )
                }
                .opacity(buttonVisible ? 1 : 0)
                .scaleEffect(buttonVisible ? 1 : 0.85)
                .animation(.spring(duration: 0.6, bounce: 0.3).delay(1.6), value: buttonVisible)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { starsExplode = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { commandsVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { buttonVisible = true }
        }
    }

    // 祝福パーティクル
    private var confettiLayer: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<20, id: \.self) { i in
                    Image(systemName: i % 3 == 0 ? "sparkle" : i % 3 == 1 ? "star.fill" : "circle.fill")
                        .font(.system(size: CGFloat.random(in: 6...14)))
                        .foregroundStyle(
                            [Color.gitStarAccent,
                             Color(red: 1, green: 0.85, blue: 0.4),
                             Color(red: 0.6, green: 1, blue: 0.75)
                            ][i % 3].opacity(starsExplode ? 0 : 0.9)
                        )
                        .position(
                            x: starsExplode
                                ? CGFloat.random(in: 20...geo.size.width - 20)
                                : geo.size.width / 2,
                            y: starsExplode
                                ? CGFloat.random(in: 20...geo.size.height * 0.6)
                                : geo.size.height * 0.35
                        )
                        .animation(
                            .easeOut(duration: 1.2).delay(Double(i) * 0.04),
                            value: starsExplode
                        )
                }
            }
        }
    }
}
