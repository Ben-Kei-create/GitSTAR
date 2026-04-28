//
//  Arc4ReflogPrototype.swift
//  gitStar
//
//  Arc 4「黄泉返りの reflog」シーンのプロトタイプ。
//  本作の感情のピークを、世界観ビジュアル基盤を全部使って実装。
//
//  - 背景レイヤー（MidnightCrisisBG）
//  - うっすら Git フロー図（GhostFlowLayer）
//  - キャラクター立ち絵（Komi / Master / Bran）
//  - ノイズ・グリッチ演出（WorldMood）
//  - インタラクティブな reflog ハッシュ選択
//

import SwiftUI

// ════════════════════════════════════════════════════════
// MARK: - シーンのビート定義
// ════════════════════════════════════════════════════════

private struct Beat {
    let speaker: CharacterID
    let text: String
    let mood: WorldMood
    var branRes: Double            // ブランの解像度
    var komiRes: Double = 0.85     // コミの解像度
    var masterRes: Double = 1.0    // マスターの解像度
    var worldHealth: Double        // 世界の修復値
    var triggersReflog: Bool = false
    var afterRescue: Bool = false
}

private let scriptBeats: [Beat] = [
    // ── Phase 1: 静寂 ──
    Beat(speaker: .komi,
         text: "今日は……\n静かだね。",
         mood: .calm, branRes: 1.0,
         worldHealth: 0.45),
    Beat(speaker: .komi,
         text: "あれ……？\nブランの声が……\n聞こえない。",
         mood: .tension, branRes: 0.6,
         worldHealth: 0.40),

    // ── Phase 2: 危機 ──
    Beat(speaker: .master,
         text: "……来たか。\ngit gc が、始まった。",
         mood: .crisis, branRes: 0.30,
         worldHealth: 0.32),
    Beat(speaker: .master,
         text: "ブランは、\nどの参照からも外れた。\n消えかけている。",
         mood: .crisis, branRes: 0.18,
         komiRes: 0.65,
         worldHealth: 0.28),

    // ── Phase 3: 探索 ──
    Beat(speaker: .master,
         text: "git log では、もう辿れん。\n通常の歴史からは、\nブランは消えた。",
         mood: .crisis, branRes: 0.10,
         komiRes: 0.55,
         worldHealth: 0.25),

    // ── Phase 4: 啓示 ──
    Beat(speaker: .master,
         text: "禁忌の技だ。\nだが、それしか道はない。",
         mood: .climax, branRes: 0.06,
         komiRes: 0.5,
         worldHealth: 0.22),
    Beat(speaker: .master,
         text: "git reflog ——\n『神の記憶』を、覗け。",
         mood: .climax, branRes: 0.05,
         komiRes: 0.5,
         worldHealth: 0.22,
         triggersReflog: true),

    // ── Phase 5: 救出後 ──
    Beat(speaker: .bran,
         text: "……ぼく、\n消えかけてた？",
         mood: .hope, branRes: 1.0,
         komiRes: 0.95,
         worldHealth: 0.65,
         afterRescue: true),
    Beat(speaker: .komi,
         text: "うん。\nでも、ハッシュが、\n君を覚えてた。",
         mood: .hope, branRes: 1.0,
         komiRes: 1.0,
         worldHealth: 0.68,
         afterRescue: true),
    Beat(speaker: .master,
         text: "覚えておけ。\n世界の表側から消えたものでも、\nreflog は決して忘れない。",
         mood: .hope, branRes: 1.0,
         komiRes: 1.0,
         worldHealth: 0.70,
         afterRescue: true),
]

// ════════════════════════════════════════════════════════
// MARK: - メインプロトタイプ View
// ════════════════════════════════════════════════════════

struct Arc4ReflogPrototype: View {
    let onExit: () -> Void

    @State private var beatIdx: Int = 0
    @State private var displayedText: String = ""
    @State private var isTyping: Bool = false
    @State private var typingTask: Task<Void, Never>?

    @State private var branRes:    Double = 1.0
    @State private var komiRes:    Double = 0.85
    @State private var masterRes:  Double = 1.0
    @State private var worldHealth: Double = 0.45
    @State private var mood: WorldMood = .calm

    @State private var reflogVisible: Bool = false
    @State private var rescueAnimating: Bool = false

    // ゴーストレイヤー用ダミー git
    private var demoGit: GitState {
        let g = GitState()
        g.isInitialized = true
        g.branches = ["main", "feature/rescue"]
        g.currentBranch = "main"
        g.commits = [
            .init(hash: "a3f8b2c", message: "world init", branch: "main"),
            .init(hash: "d6c9f7b", message: "rebuild village", branch: "main"),
            .init(hash: "c5d0e8a", message: "shore up east wall", branch: "feature/rescue"),
            .init(hash: "b4e1c9d", message: "branchwork (Bran's last)", branch: "feature/rescue"),
            .init(hash: "f2a8d3e", message: "main repair", branch: "main"),
        ]
        return g
    }

    private var currentBeat: Beat? {
        beatIdx < scriptBeats.count ? scriptBeats[beatIdx] : nil
    }

    var body: some View {
        ZStack {
            // ── Layer 0: 背景 ──
            BackgroundRegistry.backgroundForArc(4)
                .makeView(
                    health: WorldHealth(value: worldHealth),
                    mood: mood
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: worldHealth)
                .animation(.easeInOut(duration: 0.8), value: mood)

            // ── Layer 1: Git フローうっすら ──
            GhostFlowLayer(git: demoGit, baseOpacity: 0.06)
                .padding(.top, 70)
                .padding(.bottom, 230)
                .padding(.horizontal, 12)
                .ignoresSafeArea()

            // ── Layer 2: キャラクター立ち絵 ──
            characterStandees
                .allowsHitTesting(false)

            // ── Layer 3: ダイアログ ──
            VStack(spacing: 0) {
                Spacer()
                dialoguePanel
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
            }

            // ── Reflog 介入オーバーレイ ──
            if reflogVisible {
                ReflogOverlay(
                    targetHash: "b4e1c9d",
                    onCorrect: { performRescue() },
                    onCancel: { withAnimation { reflogVisible = false } }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }

            // ── 終了ボタン ──
            VStack {
                HStack {
                    Spacer()
                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    .padding(.top, 56)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear { applyBeat(0); startTyping() }
    }

    // ── キャラクター立ち絵レイヤー ──
    @ViewBuilder
    private var characterStandees: some View {
        GeometryReader { geo in
            // Bran (中央、解像度に応じて消失)
            if branRes > 0.04 {
                CharacterRegistry.artwork(for: .bran)
                    .makeView(resolution: CharacterResolution(value: branRes))
                    .scaleEffect(0.85 + branRes * 0.2)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.34)
                    .animation(.easeInOut(duration: 0.9), value: branRes)
            }

            // Komi (左下)
            CharacterRegistry.artwork(for: .komi)
                .makeView(resolution: CharacterResolution(value: komiRes))
                .scaleEffect(0.55)
                .position(x: geo.size.width * 0.18, y: geo.size.height * 0.55)
                .animation(.easeInOut(duration: 0.9), value: komiRes)

            // Master (右下)
            CharacterRegistry.artwork(for: .master)
                .makeView(resolution: CharacterResolution(value: masterRes))
                .scaleEffect(0.55)
                .position(x: geo.size.width * 0.82, y: geo.size.height * 0.55)
        }
    }

    // ── ダイアログパネル ──
    @ViewBuilder
    private var dialoguePanel: some View {
        if let beat = currentBeat {
            let speaker = Character.of(beat.speaker)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(speaker.tint)
                        .frame(width: 8, height: 8)
                    Text(speaker.name)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(speaker.tint.opacity(0.9))
                        .tracking(2)
                    Spacer()
                    Text("\(beatIdx + 1) / \(scriptBeats.count)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                }

                Text(displayedText)
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .lineSpacing(7)
                    .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)

                HStack {
                    Spacer()
                    if isTyping {
                        Text("スキップ")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                    } else if beat.triggersReflog {
                        HStack(spacing: 6) {
                            Image(systemName: "terminal.fill")
                                .font(.system(size: 11))
                            Text("git reflog を呼び出す")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color(red: 0.9, green: 0.7, blue: 0.4))
                    } else {
                        HStack(spacing: 6) {
                            Text("次へ")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(.cyan)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(speaker.tint.opacity(0.3), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
            .onTapGesture { handleTap() }
        }
    }

    // ── ロジック ──
    private func handleTap() {
        if isTyping {
            typingTask?.cancel()
            displayedText = currentBeat?.text ?? ""
            isTyping = false
            return
        }

        guard let beat = currentBeat else { return }
        if beat.triggersReflog {
            withAnimation(.easeInOut(duration: 0.6)) {
                reflogVisible = true
            }
        } else {
            advanceBeat()
        }
    }

    private func advanceBeat() {
        let next = beatIdx + 1
        if next < scriptBeats.count {
            beatIdx = next
            applyBeat(next)
            startTyping()
        }
    }

    private func applyBeat(_ idx: Int) {
        guard idx < scriptBeats.count else { return }
        let b = scriptBeats[idx]
        withAnimation(.easeInOut(duration: 0.9)) {
            branRes = b.branRes
            komiRes = b.komiRes
            masterRes = b.masterRes
            worldHealth = b.worldHealth
            mood = b.mood
        }
    }

    private func performRescue() {
        // ── 救出演出 ──
        withAnimation(.easeInOut(duration: 1.5)) {
            reflogVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            advanceBeat()  // → "ぼく、消えかけてた？"
        }
    }

    private func startTyping() {
        guard let line = currentBeat?.text else { return }
        typingTask?.cancel()
        displayedText = ""
        isTyping = true

        typingTask = Task {
            for char in line {
                if Task.isCancelled { break }
                await MainActor.run { displayedText.append(char) }
                let delay: UInt64 = char == "\n" ? 110_000_000 : 38_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
            await MainActor.run { isTyping = false }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Reflog インタラクティブオーバーレイ
// ════════════════════════════════════════════════════════

private struct ReflogOverlay: View {
    let targetHash: String
    let onCorrect: () -> Void
    let onCancel: () -> Void

    @State private var glowPulse: Double = 0.5
    @State private var wrongShake: Bool = false
    @State private var feedback: String? = nil

    private let entries: [(hash: String, action: String)] = [
        ("f8a23bc", "commit: rebuild east wall"),
        ("e7c45d1", "checkout: feature/rescue"),
        ("d6c9f7b", "commit: rebuild village"),
        ("c5d0e8a", "commit: shore up east wall"),
        ("b4e1c9d", "commit: branchwork"),       // ← target
        ("a3f8b2c", "commit: world init"),
        ("9d2e7c0", "merge: feature/init"),
        ("8c1b4d9", "checkout: main"),
        ("7a9f6e3", "commit: foundation stones"),
        ("6b8c2d4", "commit: first stars"),
        ("5e7d9a1", "commit: dawn ritual"),
        ("4f8c3b2", "checkout: feature/early"),
        ("3a2c1d5", "commit: lost prayer"),
        ("2d4f9b7", "commit: silence break"),
        ("1e8a3c0", "init: original tree"),
    ]

    var body: some View {
        ZStack {
            // 暗黒背景
            Color.black.opacity(0.93).ignoresSafeArea()

            VStack(spacing: 14) {
                // ── ヘッダー ──
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 0.9, green: 0.7, blue: 0.4))
                        Text("git reflog")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.9, green: 0.7, blue: 0.4))
                            .tracking(3)
                    }
                    Text("『神の記憶』が今、君に開かれた。")
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(.white.opacity(0.55))
                    Text("ブランの最後のハッシュを見つけ出せ。")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.52, green: 0.92, blue: 0.65).opacity(0.8))
                }
                .padding(.top, 56)

                Divider()
                    .background(Color.white.opacity(0.15))
                    .padding(.horizontal, 30)

                // ── ハッシュリスト ──
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(entries.enumerated()), id: \.element.hash) { i, entry in
                            HashRow(
                                hash: entry.hash,
                                action: entry.action,
                                index: entries.count - 1 - i,
                                isTarget: entry.hash == targetHash,
                                glowPulse: glowPulse,
                                onTap: { tapped(entry.hash) }
                            )
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .offset(x: wrongShake ? -8 : 0)
                .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: wrongShake)

                // ── フィードバック ──
                if let fb = feedback {
                    Text(fb)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                        .transition(.opacity)
                        .padding(.top, 4)
                }

                Spacer(minLength: 16)

                // ── キャンセル ──
                Button(action: onCancel) {
                    Text("一度戻る")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 36)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                glowPulse = 1.0
            }
        }
    }

    private func tapped(_ hash: String) {
        if hash == targetHash {
            withAnimation { feedback = "✓ git checkout \(hash) — ブランを引き戻す！" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { onCorrect() }
        } else {
            withAnimation {
                feedback = "違う……ブランのハッシュじゃない。"
                wrongShake.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { feedback = nil }
            }
        }
    }
}

private struct HashRow: View {
    let hash: String
    let action: String
    let index: Int
    let isTarget: Bool
    let glowPulse: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text("[\(hash)]")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(
                        isTarget
                        ? Color(red: 0.52, green: 0.92, blue: 0.65)
                            .opacity(0.65 + glowPulse * 0.35)
                        : .white.opacity(0.45)
                    )
                Text("HEAD@{\(index)}")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.28))
                Text(action)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.white.opacity(isTarget ? 0.7 : 0.35))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isTarget
                ? Color(red: 0.52, green: 0.92, blue: 0.65)
                    .opacity(0.05 + glowPulse * 0.06)
                : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isTarget
                        ? Color(red: 0.52, green: 0.92, blue: 0.65)
                            .opacity(0.2 + glowPulse * 0.3)
                        : Color.clear,
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
