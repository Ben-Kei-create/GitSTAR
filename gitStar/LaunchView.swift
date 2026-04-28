//
//  LaunchView.swift
//  gitStar
//

import SwiftUI

struct LaunchView: View {
    let onContinue: () -> Void
    let onNewGame: () -> Void
    var onPrototype: (() -> Void)? = nil

    @State private var starOpacities: [Double] = (0..<60).map { _ in Double.random(in: 0.1...0.9) }
    @State private var twinkleTrigger = false
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9
    @State private var glowPulse = false
    @State private var starGlowScale: CGFloat = 1.0
    @State private var starGlowOpacity: Double = 0.6
    @State private var shootingStarVisible = false
    @State private var shootingStarX: CGFloat = -100
    @State private var shootingStarY: CGFloat = 100
    @State private var showMenu = false           // START → メニュー展開
    @State private var showNewGameConfirm = false // 上書き確認ダイアログ

    private var hasSave: Bool {
        let save = SaveManager.load()
        return save.arcIndex > 0 || save.episodeIndex > 0
    }

    private var saveLabel: String {
        let save = SaveManager.load()
        let arcNames = [
            "Arc 1：ひとり開発編",
            "Arc 2：チーム入門編",
            "Arc 3：チーム実戦編",
            "Arc 4：緊急対応編",
            "Arc 5：熟練者編",
            "Arc 6：チームリード編"
        ]
        let name = arcNames[safe: save.arcIndex] ?? "Arc \(save.arcIndex + 1)"
        return name
    }

    private struct StarData {
        let x, y, size: CGFloat
        let baseOpacity: Double
        let twinkleSpeed: Double
    }
    private let stars: [StarData] = (0..<60).map { _ in
        StarData(
            x: .random(in: 0...1), y: .random(in: 0...1),
            size: .random(in: 1...3),
            baseOpacity: .random(in: 0.2...0.8),
            twinkleSpeed: .random(in: 0.8...2.5)
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 夜空背景
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.08),
                        Color(red: 0.04, green: 0.06, blue: 0.14),
                        Color(red: 0.06, green: 0.10, blue: 0.20),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // 星雲もや
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(red: 0.3, green: 0.4, blue: 0.8).opacity(0.08), .clear],
                        center: .center, startRadius: 0, endRadius: geo.size.width * 0.6
                    ))
                    .frame(width: geo.size.width * 1.2)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.35)

                // 流れ星
                if shootingStarVisible {
                    ShootingStarView()
                        .position(x: shootingStarX, y: shootingStarY)
                }

                // 星空まばたき
                ForEach(0..<stars.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(starOpacities[i]))
                        .frame(width: stars[i].size)
                        .position(x: stars[i].x * geo.size.width, y: stars[i].y * geo.size.height)
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

                    // ロゴ
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            Text("Git")
                                .font(.system(size: 52, weight: .thin, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.85))
                                .tracking(4)
                            ZStack {
                                Text("STAR")
                                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                                    .foregroundStyle(Color.gitStarAccent)
                                    .tracking(4)
                                    .blur(radius: 8)
                                    .opacity(glowPulse ? 0.6 : 0.2)
                                    .scaleEffect(glowPulse ? 1.02 : 1.0)
                                Text("STAR")
                                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                                    .foregroundStyle(LinearGradient(
                                        colors: [.white, Color(red: 0.7, green: 0.92, blue: 1.0), .white],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .tracking(4)
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

                    // ── ボタンエリア ──
                    ZStack {
                        // START ボタン（メニュー展開前）
                        if !showMenu {
                            startButton
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        // ゲームメニュー
                        if showMenu {
                            gameMenu
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .animation(.spring(duration: 0.45, bounce: 0.3), value: showMenu)
                    .opacity(buttonOpacity)
                    .scaleEffect(buttonScale)

                    Text("© GitSTAR — 記録者の村")
                        .font(.system(size: 10, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.2))
                        .tracking(3)
                        .padding(.top, 28)
                        .padding(.bottom, 48)
                        .opacity(buttonOpacity)
                }
            }
        }
        .onAppear { startAnimations() }
        // ニューゲーム確認ダイアログ
        .confirmationDialog(
            "セーブデータを上書きしますか？",
            isPresented: $showNewGameConfirm,
            titleVisibility: .visible
        ) {
            Button("ニューゲームを始める", role: .destructive) {
                SaveManager.reset()
                onNewGame()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("\(saveLabel) のセーブデータが消えます。")
        }
    }

    // MARK: - START ボタン
    private var startButton: some View {
        Button {
            withAnimation { showMenu = true }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "star.fill").font(.system(size: 12))
                Text("START")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .tracking(8)
                Image(systemName: "star.fill").font(.system(size: 12))
            }
            .foregroundStyle(Color.gitStarBackground)
            .padding(.horizontal, 40).padding(.vertical, 16)
            .background(
                ZStack {
                    Capsule().fill(Color.gitStarAccent)
                    Capsule().fill(Color.white.opacity(0.15)).padding(1)
                }
            )
            .shadow(color: Color.gitStarAccent.opacity(0.6), radius: 20)
        }
    }

    // MARK: - ゲームメニュー
    private var gameMenu: some View {
        VStack(spacing: 14) {
            // セーブがある場合のみ「続きから」
            if hasSave {
                // 続きから
                Button(action: onContinue) {
                    HStack(spacing: 14) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gitStarAccent)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("続きから")
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                                .tracking(2)
                            Text(saveLabel)
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(.white.opacity(0.45))
                                .tracking(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.gitStarAccent.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gitStarAccent.opacity(0.4), lineWidth: 1)
                            )
                    )
                }

                // ニューゲーム（上書き確認あり）
                Button {
                    showNewGameConfirm = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("ニューゲーム")
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.7))
                            .tracking(2)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.2))
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                }

            } else {
                // セーブなし → ニューゲームのみ（確認なし）
                Button(action: onNewGame) {
                    HStack(spacing: 16) {
                        Image(systemName: "star.fill").font(.system(size: 12))
                        Text("ニューゲーム")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .tracking(4)
                        Image(systemName: "star.fill").font(.system(size: 12))
                    }
                    .foregroundStyle(Color.gitStarBackground)
                    .padding(.horizontal, 36).padding(.vertical, 16)
                    .background(
                        ZStack {
                            Capsule().fill(Color.gitStarAccent)
                            Capsule().fill(Color.white.opacity(0.15)).padding(1)
                        }
                    )
                    .shadow(color: Color.gitStarAccent.opacity(0.6), radius: 20)
                }
            }

            // 戻るボタン
            Button {
                withAnimation { showMenu = false }
            } label: {
                Text("もどる")
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                    .tracking(3)
            }
            .padding(.top, 4)

            // プロトタイプボタン（開発用）
            if let onPrototype {
                Button(action: onPrototype) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("Arc 4 reflog プロトタイプ")
                            .font(.system(size: 11, weight: .light, design: .monospaced))
                            .tracking(2)
                    }
                    .foregroundStyle(Color(red: 0.9, green: 0.7, blue: 0.4).opacity(0.55))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.9, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.top, 16)
            }
        }
        .padding(.horizontal, 40)
    }

    // MARK: - アニメーション開始
    private func startAnimations() {
        twinkleTrigger.toggle()
        updateTwinkle()
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) { titleOpacity = 1; titleOffset = 0 }
        withAnimation(.easeOut(duration: 1.0).delay(0.9)) { subtitleOpacity = 1 }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.8)) { glowPulse = true }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            starGlowScale = 1.15; starGlowOpacity = 1.0
        }
        withAnimation(.spring(duration: 0.8, bounce: 0.3).delay(1.6)) {
            buttonOpacity = 1; buttonScale = 1.0
        }
        shootShootingStar()
    }

    private func updateTwinkle() {
        for i in 0..<starOpacities.count {
            let newOpacity = Double.random(in: 0.1...1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 0...3)) {
                withAnimation(.easeInOut(duration: stars[i].twinkleSpeed)) {
                    starOpacities[i] = newOpacity
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { updateTwinkle() }
    }

    private func shootShootingStar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 2...5)) {
            shootingStarX = .random(in: 50...300)
            shootingStarY = .random(in: 80...250)
            shootingStarVisible = true
            withAnimation(.linear(duration: 0.6)) {
                shootingStarX += 180; shootingStarY += 80
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
        (-30, -28, 8, 0.0), (45, -20, 12, 0.3), (55, 18, 7, 0.6),
        (-18, 32, 9, 0.2),  (15, -38, 6, 0.5),  (-42, 10, 7, 0.8),
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
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(sparkles[i].delay),
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
                .fill(LinearGradient(colors: [.white, .white.opacity(0)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 60, height: 1.5)
                .rotationEffect(.degrees(22))
            Circle().fill(Color.white).frame(width: 3, height: 3).offset(x: -28)
        }
    }
}

extension Color {
    static let gitStarBackground = Color(red: 0.04, green: 0.05, blue: 0.09)
    static let gitStarDeepBlue   = Color(red: 0.06, green: 0.09, blue: 0.16)
    static let gitStarPanel      = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let gitStarAccent     = Color(red: 0.56, green: 0.85, blue: 1.00)
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    LaunchView(onContinue: {}, onNewGame: {})
}
