//
//  LaunchView.swift
//  gitStar
//

import SwiftUI

struct LaunchView: View {
    let onStart: () -> Void

    @State private var starOpacities: [Double] = (0..<60).map { _ in Double.random(in: 0.1...0.9) }
    @State private var twinkleTrigger = false
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9
    @State private var glowPulse = false
    @State private var shootingStarVisible = false
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 100
    @State private var starGlowScale: CGFloat = 1.0
    @State private var starGlowOpacity: Double = 0.6

    // 星の位置（固定）
    private struct StarData {
        let x, y, size: CGFloat
        let baseOpacity: Double
        let twinkleSpeed: Double
    }
    private let stars: [StarData] = (0..<60).map { _ in
        StarData(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 1...3),
            baseOpacity: Double.random(in: 0.2...0.8),
            twinkleSpeed: Double.random(in: 0.8...2.5)
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景グラデーション（夜空）
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.08),
                        Color(red: 0.04, green: 0.06, blue: 0.14),
                        Color(red: 0.06, green: 0.10, blue: 0.20),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // 星雲っぽい淡い光
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.3, green: 0.4, blue: 0.8).opacity(0.08),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.6
                        )
                    )
                    .frame(width: geo.size.width * 1.2)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.35)

                // 流れ星
                if shootingStarVisible {
                    ShootingStarView()
                        .position(x: shootingStarX, y: shootingStarY)
                }

                // 星空（まばたき）
                ForEach(0..<stars.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(starOpacities[i]))
                        .frame(width: stars[i].size)
                        .position(
                            x: stars[i].x * geo.size.width,
                            y: stars[i].y * geo.size.height
                        )
                        .animation(
                            .easeInOut(duration: stars[i].twinkleSpeed)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.05),
                            value: twinkleTrigger
                        )
                }

                // メインコンテンツ
                VStack(spacing: 0) {
                    Spacer()

                    // ロゴエリア
                    VStack(spacing: 20) {

                        // Git + STAR (STAR がキラっと)
                        HStack(spacing: 0) {
                            Text("Git")
                                .font(.system(size: 52, weight: .thin, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.85))
                                .tracking(4)

                            ZStack {
                                // STAR の後光
                                Text("STAR")
                                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                                    .foregroundStyle(Color.gitStarAccent)
                                    .tracking(4)
                                    .blur(radius: 8)
                                    .opacity(glowPulse ? 0.6 : 0.2)
                                    .scaleEffect(glowPulse ? 1.02 : 1.0)

                                // STAR 本体
                                Text("STAR")
                                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.white,
                                                Color(red: 0.7, green: 0.92, blue: 1.0),
                                                Color.white,
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .tracking(4)

                                // キラキラ sparkle たち
                                SparkleCluster(scale: starGlowScale, opacity: starGlowOpacity)
                            }
                        }

                        Text("記録者の旅、はじまる。")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(.white.opacity(0.45))
                            .tracking(6)
                            .opacity(subtitleOpacity)
                    }
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                    Spacer()

                    // START ボタン
                    Button(action: onStart) {
                        HStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.gitStarBackground)
                            Text("START")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color.gitStarBackground)
                                .tracking(8)
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.gitStarBackground)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                Capsule().fill(Color.gitStarAccent)
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .padding(1)
                            }
                        )
                        .shadow(color: Color.gitStarAccent.opacity(0.6), radius: 20, x: 0, y: 0)
                    }
                    .opacity(buttonOpacity)
                    .scaleEffect(buttonScale)

                    Text("© GitSTAR — 記録者の村")
                        .font(.system(size: 10, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.2))
                        .tracking(3)
                        .padding(.top, 32)
                        .padding(.bottom, 48)
                        .opacity(buttonOpacity)
                }
            }
        }
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        // 星まばたき開始
        twinkleTrigger.toggle()
        updateTwinkle()

        // タイトル フェードイン
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            titleOpacity = 1
            titleOffset = 0
        }
        withAnimation(.easeOut(duration: 1.0).delay(0.9)) {
            subtitleOpacity = 1
        }

        // グロー パルス
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.8)) {
            glowPulse = true
        }

        // STAR キラキラ
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            starGlowScale = 1.15
            starGlowOpacity = 1.0
        }

        // ボタン フェードイン
        withAnimation(.spring(duration: 0.8, bounce: 0.3).delay(1.6)) {
            buttonOpacity = 1
            buttonScale = 1.0
        }

        // 流れ星
        shootShootingStar()
    }

    private func updateTwinkle() {
        for i in 0..<starOpacities.count {
            let newOpacity = Double.random(in: 0.1...1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
                withAnimation(.easeInOut(duration: stars[i].twinkleSpeed)) {
                    starOpacities[i] = newOpacity
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            updateTwinkle()
        }
    }

    private func shootShootingStar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...5)) {
            shootingStarX = CGFloat.random(in: 50...300)
            shootingStarY = CGFloat.random(in: 80...250)
            withAnimation(.linear(duration: 0)) {
                shootingStarVisible = true
            }
            withAnimation(.linear(duration: 0.6)) {
                shootingStarX += 180
                shootingStarY += 80
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                shootingStarVisible = false
                shootShootingStar()
            }
        }
    }
}

// MARK: - キラキラクラスター
struct SparkleCluster: View {
    let scale: CGFloat
    let opacity: Double

    private let sparkles: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (-30, -28,  8, 0.0),
        ( 45, -20, 12, 0.3),
        ( 55,  18,  7, 0.6),
        (-18,  32,  9, 0.2),
        ( 15, -38,  6, 0.5),
        (-42,  10,  7, 0.8),
    ]

    var body: some View {
        ZStack {
            ForEach(0..<sparkles.count, id: \.self) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: sparkles[i].size))
                    .foregroundStyle(Color.white.opacity(opacity * 0.9))
                    .scaleEffect(scale)
                    .offset(x: sparkles[i].x, y: sparkles[i].y)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(sparkles[i].delay),
                        value: scale
                    )
            }
        }
    }
}

// MARK: - 流れ星
struct ShootingStarView: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 60, height: 1.5)
                .rotationEffect(.degrees(22))

            Circle()
                .fill(Color.white)
                .frame(width: 3, height: 3)
                .offset(x: -28)
        }
    }
}

extension Color {
    static let gitStarBackground = Color(red: 0.04, green: 0.05, blue: 0.09)
    static let gitStarDeepBlue   = Color(red: 0.06, green: 0.09, blue: 0.16)
    static let gitStarPanel      = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let gitStarAccent     = Color(red: 0.56, green: 0.85, blue: 1.00)
}

#Preview {
    LaunchView(onStart: {})
}
