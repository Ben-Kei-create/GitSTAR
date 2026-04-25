//
//  CityStageView.swift
//  gitStar
//

import SwiftUI

// MARK: - メイン
struct CityStageView: View {
    let git: GitState
    let arcNumber: Int

    @State private var pulsedArea: GitArea? = nil
    @State private var flyingParticles: [FlyingParticle] = []

    // カードX位置（幅の割合）
    private let cardXFractions: [GitArea: CGFloat] = [
        .working: 0.115, .staging: 0.37, .repo: 0.63, .remote: 0.885
    ]
    // コマンド → (from, to) のマッピング
    private let flightMap: [GitArea: (from: GitArea, to: GitArea)] = [
        .staging: (from: .working,  to: .staging),
        .repo:    (from: .staging,  to: .repo),
        .remote:  (from: .repo,     to: .remote),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [.gitStarBackground, .gitStarDeepBlue],
                    startPoint: .top, endPoint: .bottom
                )
                StarsView()

                VStack(spacing: 0) {
                    // ヘッダー
                    HStack {
                        Text("GitSTAR")
                            .font(.system(size: 18, weight: .thin, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.7))
                            .tracking(6)
                        Spacer()
                        HStack(spacing: 8) {
                            Text("Arc \(arcNumber)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.gitStarAccent.opacity(0.6))
                                .tracking(2)
                            if git.isInitialized {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(branchColor(git.currentBranch))
                                        .frame(width: 5, height: 5)
                                    Text(git.currentBranch)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundStyle(branchColor(git.currentBranch).opacity(0.85))
                                }
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(branchColor(git.currentBranch).opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 14)

                    Spacer()

                    // ── メインビジュアル切り替え ──
                    if git.branches.count > 1 {
                        BranchTreeView(git: git)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 14)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    } else {
                        FourAreaView(git: git, pulsedArea: pulsedArea)
                            .padding(.horizontal, 14)
                            .transition(.opacity)
                    }

                    Spacer()
                }

                // ── 飛行パーティクル（絶対位置オーバーレイ） ──
                ForEach(flyingParticles) { p in
                    FlyingParticleView(particle: p)
                }
            }
            .onChange(of: git.lastPulsedArea) { (_: GitArea?, newArea: GitArea?) in
                guard let area = newArea else { return }

                // カードパルス
                withAnimation(.easeOut(duration: 0.15)) { pulsedArea = area }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.easeOut(duration: 0.4)) { pulsedArea = nil }
                }

                // ファイル飛行
                if let flight = flightMap[area],
                   let fromX = cardXFractions[flight.from],
                   let toX   = cardXFractions[flight.to] {
                    let cardY = geo.size.height * 0.53
                    let symbol = area == .remote ? "circle.fill" : "doc.fill"
                    let color  = area == .remote
                        ? Color(red: 0.85, green: 0.65, blue: 1.0)
                        : (area == .repo ? Color(red: 0.6, green: 1.0, blue: 0.75)
                                        : Color(red: 1.0, green: 0.85, blue: 0.5))
                    let p = FlyingParticle(
                        id: UUID(),
                        from: CGPoint(x: fromX * geo.size.width, y: cardY),
                        to:   CGPoint(x: toX   * geo.size.width, y: cardY),
                        symbol: symbol, color: color
                    )
                    flyingParticles.append(p)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        flyingParticles.removeAll { $0.id == p.id }
                    }
                }
            }
        }
        .animation(.spring(duration: 0.5), value: git.branches.count)
    }
}

// MARK: - 4エリアカード（Arc 1 用）
struct FourAreaView: View {
    let git: GitState
    let pulsedArea: GitArea?

    var body: some View {
        HStack(spacing: 8) {
            GitAreaCard(icon: "pencil",            label: "Working",  sublabel: "作業部屋",
                        color: Color(red: 0.6, green: 0.8, blue: 1.0),
                        count: git.workingFiles.count, items: git.workingFiles.map(\.name),
                        isActive: !git.workingFiles.isEmpty, isPulsing: pulsedArea == .working)
            FlowArrow(label: "add")
            GitAreaCard(icon: "shippingbox",       label: "Staging",  sublabel: "宅配ボックス",
                        color: Color(red: 1.0, green: 0.85, blue: 0.5),
                        count: git.stagedFiles.count, items: git.stagedFiles.map(\.name),
                        isActive: !git.stagedFiles.isEmpty, isPulsing: pulsedArea == .staging)
            FlowArrow(label: "commit")
            GitAreaCard(icon: "building.columns",  label: "Repo",     sublabel: "役所",
                        color: Color(red: 0.6, green: 1.0, blue: 0.75),
                        count: git.commits.count, items: git.commits.suffix(2).map { "[\($0.hash)]" },
                        isActive: !git.commits.isEmpty, isPulsing: pulsedArea == .repo)
            FlowArrow(label: "push")
            GitAreaCard(icon: "network",            label: "Remote",   sublabel: "隣村",
                        color: Color(red: 0.85, green: 0.65, blue: 1.0),
                        count: git.pushedCount, items: git.remoteName.map { [$0] } ?? [],
                        isActive: git.remoteName != nil, isPulsing: pulsedArea == .remote)
        }
    }
}

// MARK: - ブランチツリー（Arc 2+ 用）
struct BranchTreeView: View {
    let git: GitState

    private let rowH: CGFloat = 52
    private let dotR: CGFloat = 7
    private let leftPad: CGFloat = 70
    private let colW: CGFloat = 52

    private func color(_ branch: String) -> Color { branchColor(branch) }

    // ブランチ → 行インデックス
    private var branchRow: [String: Int] {
        var d: [String: Int] = [:]
        var i = 0
        for b in git.branches {
            d[b] = i; i += 1
        }
        return d
    }

    // コミット → X 座標（時系列順）
    private func commitX(_ idx: Int) -> CGFloat { leftPad + CGFloat(idx) * colW }
    private func branchY(_ branch: String, in h: CGFloat) -> CGFloat {
        let row = CGFloat(branchRow[branch] ?? 0)
        let total = CGFloat(max(git.branches.count, 1))
        let usable = h - 24
        return 12 + row * (usable / total) + (usable / total) / 2
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── ブランチ名ラベル ──
                ForEach(git.branches, id: \.self) { branch in
                    let y = branchY(branch, in: geo.size.height)
                    HStack(spacing: 5) {
                        Circle().fill(color(branch)).frame(width: 6, height: 6)
                        Text(branch)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(color(branch).opacity(0.8))
                            .lineLimit(1)
                    }
                    .frame(width: leftPad - 8, alignment: .leading)
                    .position(x: (leftPad - 8) / 2 + 2, y: y)
                }

                // ── ライン & ドット ──
                Canvas { ctx, size in
                    let commits = git.commits

                    // 各ブランチのコミット列を線で繋ぐ
                    for branch in git.branches {
                        let pts = commits.enumerated()
                            .filter { $0.element.branch == branch }
                            .map { CGPoint(x: commitX($0.offset), y: branchY(branch, in: size.height)) }
                        guard pts.count > 1 else { continue }
                        var path = Path()
                        path.move(to: pts[0])
                        for pt in pts.dropFirst() { path.addLine(to: pt) }
                        ctx.stroke(path, with: .color(color(branch).opacity(0.45)), lineWidth: 2)
                    }

                    // マージ線（異なるブランチへの繋ぎ）
                    // シンプル実装：最後の feature コミット → main の最後へ
                    if git.branches.count > 1 {
                        let mainBranch = "main"
                        let lastMainCommit = commits.enumerated().last(where: { $0.element.branch == mainBranch })
                        let featureBranches = git.branches.filter { $0 != mainBranch }
                        for fb in featureBranches {
                            if let lastFeat = commits.enumerated().last(where: { $0.element.branch == fb }),
                               let lastMain = lastMainCommit {
                                let fromPt = CGPoint(x: commitX(lastFeat.offset), y: branchY(fb, in: size.height))
                                let toPt   = CGPoint(x: commitX(lastMain.offset), y: branchY(mainBranch, in: size.height))
                                var path = Path()
                                path.move(to: fromPt)
                                path.addCurve(
                                    to: toPt,
                                    control1: CGPoint(x: fromPt.x + 16, y: fromPt.y),
                                    control2: CGPoint(x: toPt.x  - 16, y: toPt.y)
                                )
                                ctx.stroke(path, with: .color(color(fb).opacity(0.3)),
                                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                            }
                        }
                    }

                    // コミットドット
                    for (idx, commit) in commits.enumerated() {
                        let cx = commitX(idx)
                        let cy = branchY(commit.branch, in: size.height)
                        let rect = CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2)
                        ctx.fill(Path(ellipseIn: rect), with: .color(color(commit.branch)))
                        // リング
                        ctx.stroke(Path(ellipseIn: rect.insetBy(dx: -1.5, dy: -1.5)),
                                   with: .color(color(commit.branch).opacity(0.35)), lineWidth: 1)
                    }

                    // HEAD マーカー
                    if let last = commits.indices.last {
                        let cx = commitX(last)
                        let cy = branchY(commits[last].branch, in: size.height)
                        let headRect = CGRect(x: cx - dotR - 3, y: cy - dotR - 3,
                                             width: (dotR + 3) * 2, height: (dotR + 3) * 2)
                        ctx.stroke(Path(ellipseIn: headRect),
                                   with: .color(Color.white.opacity(0.5)), lineWidth: 1.5)
                    }
                }

                // コミットハッシュラベル
                ForEach(Array(git.commits.enumerated()), id: \.element.id) { idx, c in
                    Text(String(c.hash.prefix(4)))
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundStyle(color(c.branch).opacity(0.5))
                        .position(x: commitX(idx), y: branchY(c.branch, in: geo.size.height) + dotR + 10)
                }

                // コミットなし時のプレースホルダー
                if git.commits.isEmpty {
                    Text("まだコミットがないよ")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.25))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

// MARK: - ブランチカラー定義
func branchColor(_ branch: String) -> Color {
    switch branch {
    case "main":   return Color(red: 0.56, green: 0.85, blue: 1.00)
    case _ where branch.hasPrefix("feature"):
                   return Color(red: 0.52, green: 0.92, blue: 0.65)
    case _ where branch.hasPrefix("fix"), "hotfix":
                   return Color(red: 1.00, green: 0.60, blue: 0.50)
    default:       return Color(red: 1.00, green: 0.82, blue: 0.42)
    }
}

// MARK: - 飛行パーティクル
struct FlyingParticle: Identifiable {
    let id: UUID
    let from: CGPoint
    let to: CGPoint
    let symbol: String
    let color: Color
}

struct FlyingParticleView: View {
    let particle: FlyingParticle
    @State private var progress: CGFloat = 0
    @State private var opacity: Double = 1

    private var pos: CGPoint {
        let t = progress
        let arc = sin(t * .pi) * -30
        return CGPoint(
            x: particle.from.x + (particle.to.x - particle.from.x) * t,
            y: particle.from.y + (particle.to.y - particle.from.y) * t + arc
        )
    }

    var body: some View {
        Image(systemName: particle.symbol)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(particle.color.opacity(opacity))
            .shadow(color: particle.color.opacity(0.8), radius: 4)
            .position(pos)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.45)) { progress = 1.0 }
                withAnimation(.easeIn(duration: 0.2).delay(0.38)) { opacity = 0 }
            }
    }
}

// MARK: - エリアカード
struct GitAreaCard: View {
    let icon: String
    let label: String
    let sublabel: String
    let color: Color
    let count: Int
    let items: [String]
    let isActive: Bool
    let isPulsing: Bool

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isPulsing ? 0.25 : isActive ? 0.12 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(isPulsing ? 0.9 : isActive ? 0.5 : 0.15),
                                    lineWidth: isPulsing ? 1.5 : 1)
                    )
                    .scaleEffect(isPulsing ? 1.06 : 1.0)

                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(color.opacity(isActive ? 1.0 : 0.3))
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundStyle(color)
                    }
                    ForEach(items.prefix(2), id: \.self) { item in
                        Text(item)
                            .font(.system(size: 7.5, design: .monospaced))
                            .foregroundStyle(color.opacity(0.7))
                            .lineLimit(1).truncationMode(.middle)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity).frame(height: 88)
            .animation(.spring(duration: 0.3, bounce: 0.4), value: isPulsing)
            .animation(.easeInOut(duration: 0.4), value: isActive)

            Text(label)
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(isActive ? 0.8 : 0.3))
            Text(sublabel)
                .font(.system(size: 8.5, weight: .light))
                .foregroundStyle(.white.opacity(0.22))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 矢印
struct FlowArrow: View {
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "chevron.right").font(.system(size: 8, weight: .light))
            Text(label).font(.system(size: 6.5, design: .monospaced))
        }
        .foregroundStyle(.white.opacity(0.2))
    }
}

// MARK: - 星空
struct StarsView: View {
    private struct Star { let x, y, size: CGFloat; let opacity: Double }
    private let stars: [Star] = (0..<40).map { _ in
        Star(x: .random(in: 0...1), y: .random(in: 0...1),
             size: .random(in: 1...2.5), opacity: .random(in: 0.15...0.7))
    }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<stars.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(stars[i].opacity))
                        .frame(width: stars[i].size)
                        .position(x: stars[i].x * geo.size.width,
                                  y: stars[i].y * geo.size.height)
                }
            }
        }
    }
}
