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

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 背景
                LinearGradient(
                    colors: [.gitStarBackground, .gitStarDeepBlue],
                    startPoint: .top, endPoint: .bottom
                )
                StarsView()

                VStack(spacing: 0) {
                    // ── ヘッダー ──
                    headerView
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 6)

                    // ── 縦型コミットグラフ ──
                    VerticalGitGraph(git: git)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 16)

                    // ── ステータスストリップ（下部）──
                    GitStatusStrip(git: git, pulsedArea: pulsedArea)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                }

                // ── 飛行パーティクル（絶対位置オーバーレイ）──
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

                // パーティクル: ステータスストリップ上を飛ぶ
                let stripY   = geo.size.height - 22   // ストリップ中心Y
                let w        = geo.size.width
                let positions: [GitArea: CGFloat] = [
                    .working: w * 0.125,
                    .staging: w * 0.375,
                    .repo:    w * 0.625,
                    .remote:  w * 0.875,
                ]
                let flights: [GitArea: (GitArea, GitArea)] = [
                    .staging: (.working, .staging),
                    .repo:    (.staging, .repo),
                    .remote:  (.repo,    .remote),
                ]
                if let (fromArea, toArea) = flights[area],
                   let fromX = positions[fromArea],
                   let toX   = positions[toArea] {
                    let color: Color = area == .remote
                        ? Color(red: 0.85, green: 0.65, blue: 1.0)
                        : area == .repo
                            ? Color(red: 0.60, green: 1.00, blue: 0.75)
                            : Color(red: 1.00, green: 0.85, blue: 0.50)
                    let p = FlyingParticle(
                        id: UUID(),
                        from: CGPoint(x: fromX, y: stripY),
                        to:   CGPoint(x: toX,   y: stripY),
                        symbol: area == .remote ? "circle.fill" : "doc.fill",
                        color: color
                    )
                    flyingParticles.append(p)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        flyingParticles.removeAll { $0.id == p.id }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var headerView: some View {
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
                    .background(branchColor(git.currentBranch).opacity(0.12))
                    .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - 縦型コミットグラフ
struct VerticalGitGraph: View {
    let git: GitState

    private let dotR:    CGFloat = 5.5
    private let rowH:    CGFloat = 44
    private let labelH:  CGFloat = 26   // ブランチラベル行の高さ

    // 表示するコミット（古い順、最大 8 件）
    private var displayCommits: [GitState.GitCommit] {
        Array(git.commits.suffix(8))
    }

    private var branchCount: Int { max(git.branches.count, 1) }

    // ブランチインデックス → X 座標
    private func colXAt(_ idx: Int, in w: CGFloat) -> CGFloat {
        let n = branchCount
        let pad: CGFloat = 48
        let usable = w - pad * 2
        if n == 1 { return w / 2 }
        return pad + usable * CGFloat(idx) / CGFloat(n - 1)
    }

    private func colX(_ branch: String, in w: CGFloat) -> CGFloat {
        let idx = git.branches.firstIndex(of: branch) ?? 0
        return colXAt(idx, in: w)
    }

    // 表示行インデックス（0=最古）→ Y 座標
    private func rowY(_ row: Int) -> CGFloat {
        labelH + CGFloat(row) * rowH + rowH / 2
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {

                // ── 空状態のプレースホルダー ──
                if displayCommits.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: git.isInitialized ? "arrow.down.circle" : "sparkles")
                            .font(.system(size: 24, weight: .ultraLight))
                            .foregroundStyle(.white.opacity(0.18))
                        Text(git.isInitialized
                             ? "git add & commit してみよう"
                             : "git init ではじめよう")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(.white.opacity(0.22))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // ── ブランチライン & コミットドット（Canvas）──
                Canvas { ctx, size in

                    // 各ブランチの縦ライン
                    for (i, branch) in git.branches.enumerated() {
                        let x    = colXAt(i, in: size.width)
                        let topY = labelH + 4

                        // そのブランチの最後のコミット行
                        let lastRow: Int
                        if let lastIdx = displayCommits.lastIndex(where: { $0.branch == branch }) {
                            lastRow = lastIdx
                        } else {
                            lastRow = max(displayCommits.count - 1, 2)
                        }
                        let bottomY = rowY(lastRow) + dotR

                        let hasCommits = displayCommits.contains { $0.branch == branch }
                        var linePath = Path()
                        linePath.move(to: CGPoint(x: x, y: topY))
                        linePath.addLine(to: CGPoint(x: x, y: bottomY))
                        ctx.stroke(
                            linePath,
                            with: .color(branchColor(branch).opacity(hasCommits ? 0.38 : 0.15)),
                            style: StrokeStyle(
                                lineWidth: hasCommits ? 1.5 : 1.0,
                                dash: hasCommits ? [] : [5, 4]
                            )
                        )
                    }

                    // コミットドット
                    for (row, commit) in displayCommits.enumerated() {
                        let cx   = colX(commit.branch, in: size.width)
                        let cy   = rowY(row)
                        let col  = branchColor(commit.branch)
                        let rect = CGRect(x: cx - dotR, y: cy - dotR,
                                          width: dotR * 2, height: dotR * 2)
                        ctx.fill(Path(ellipseIn: rect), with: .color(col))
                        // 淡いリング
                        ctx.stroke(
                            Path(ellipseIn: rect.insetBy(dx: -2, dy: -2)),
                            with: .color(col.opacity(0.22)), lineWidth: 1
                        )
                    }

                    // HEAD リング（最新コミット = 最後の行）
                    if let headCommit = displayCommits.last {
                        let cx      = colX(headCommit.branch, in: size.width)
                        let cy      = rowY(displayCommits.count - 1)
                        let ring    = dotR + 4
                        let hrRect  = CGRect(x: cx - ring, y: cy - ring,
                                             width: ring * 2, height: ring * 2)
                        ctx.stroke(Path(ellipseIn: hrRect),
                                   with: .color(.white.opacity(0.55)), lineWidth: 1.5)
                    }

                    // コミット数が多い場合の「…」インジケーター
                    if git.commits.count > 8 {
                        let txt = AttributedString("\(git.commits.count - 8) more ↑")
                        ctx.draw(Text(txt)
                            .font(.system(size: 8, weight: .light, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.22)),
                            at: CGPoint(x: size.width / 2, y: labelH + 8),
                            anchor: .center
                        )
                    }
                }
                .frame(width: w, height: h)

                // ── ブランチラベル（ラベル行に配置）──
                ForEach(Array(git.branches.enumerated()), id: \.element) { idx, branch in
                    let x = colXAt(idx, in: w)
                    HStack(spacing: 3) {
                        Circle()
                            .fill(branchColor(branch))
                            .frame(width: 5, height: 5)
                        Text(branch)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(branchColor(branch).opacity(0.9))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .frame(maxWidth: 96, alignment: .leading)
                    .position(x: x, y: 13)
                }

                // ── コミットハッシュラベル（ドット右隣）──
                ForEach(Array(displayCommits.enumerated()), id: \.element.id) { row, commit in
                    let cx = colX(commit.branch, in: w)
                    let cy = rowY(row)
                    HStack(spacing: 0) {
                        Text(String(commit.hash.prefix(4)))
                            .font(.system(size: 7.5, design: .monospaced))
                            .foregroundStyle(branchColor(commit.branch).opacity(0.45))
                    }
                    .position(x: cx + dotR + 13, y: cy)
                }

                // ── HEAD ラベル ──
                if let headCommit = displayCommits.last {
                    let cx = colX(headCommit.branch, in: w)
                    let cy = rowY(displayCommits.count - 1)
                    Text("HEAD")
                        .font(.system(size: 7, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                        .position(x: cx, y: cy + dotR + 11)
                }
            }
        }
    }
}

// MARK: - ステータスストリップ
struct GitStatusStrip: View {
    let git: GitState
    let pulsedArea: GitArea?

    var body: some View {
        HStack(spacing: 6) {
            StatusChip(
                icon: "pencil",
                label: "作業",
                value: git.workingFiles.count,
                color: Color(red: 0.60, green: 0.80, blue: 1.00),
                isPulsing: pulsedArea == .working
            )
            StatusChip(
                icon: "shippingbox",
                label: "待機",
                value: git.stagedFiles.count,
                color: Color(red: 1.00, green: 0.85, blue: 0.50),
                isPulsing: pulsedArea == .staging
            )
            StatusChip(
                icon: "building.columns",
                label: "記録",
                value: git.commits.count,
                color: Color(red: 0.60, green: 1.00, blue: 0.75),
                isPulsing: pulsedArea == .repo,
                showZero: true
            )
            StatusChip(
                icon: "network",
                label: "リモート",
                value: git.remoteName != nil ? 1 : 0,
                color: Color(red: 0.85, green: 0.65, blue: 1.00),
                isPulsing: pulsedArea == .remote,
                showZero: false
            )
        }
    }
}

struct StatusChip: View {
    let icon:      String
    let label:     String
    let value:     Int
    let color:     Color
    let isPulsing: Bool
    var showZero:  Bool = true

    private var isActive: Bool { value > 0 }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color.opacity(isPulsing || isActive ? 0.85 : 0.28))
            if showZero || isActive {
                Text(isActive ? "\(value)" : "−")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(color.opacity(isPulsing ? 1.0 : isActive ? 0.8 : 0.22))
            }
            Text(label)
                .font(.system(size: 8.5, weight: .light))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(color.opacity(isPulsing ? 0.18 : isActive ? 0.07 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(color.opacity(isPulsing ? 0.75 : isActive ? 0.28 : 0.10), lineWidth: 1)
                )
        )
        .scaleEffect(isPulsing ? 1.07 : 1.0)
        .animation(.spring(duration: 0.28, bounce: 0.4), value: isPulsing)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ブランチカラー
func branchColor(_ branch: String) -> Color {
    switch branch {
    case "main":
        return Color(red: 0.56, green: 0.85, blue: 1.00)
    case _ where branch.hasPrefix("feature"):
        return Color(red: 0.52, green: 0.92, blue: 0.65)
    case _ where branch.hasPrefix("fix"), _ where branch.hasPrefix("hotfix"):
        return Color(red: 1.00, green: 0.60, blue: 0.50)
    default:
        return Color(red: 1.00, green: 0.82, blue: 0.42)
    }
}

// MARK: - 飛行パーティクル
struct FlyingParticle: Identifiable {
    let id: UUID
    let from: CGPoint
    let to:   CGPoint
    let symbol: String
    let color:  Color
}

struct FlyingParticleView: View {
    let particle: FlyingParticle
    @State private var progress: CGFloat = 0
    @State private var opacity:  Double  = 1

    private var pos: CGPoint {
        let t   = progress
        let arc = sin(t * .pi) * -28
        return CGPoint(
            x: particle.from.x + (particle.to.x - particle.from.x) * t,
            y: particle.from.y + (particle.to.y - particle.from.y) * t + arc
        )
    }

    var body: some View {
        Image(systemName: particle.symbol)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(particle.color.opacity(opacity))
            .shadow(color: particle.color.opacity(0.9), radius: 4)
            .position(pos)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.42)) { progress = 1.0 }
                withAnimation(.easeIn(duration: 0.18).delay(0.35)) { opacity = 0 }
            }
    }
}

// MARK: - 星空
struct StarsView: View {
    private struct Star { let x, y, size: CGFloat; let opacity: Double }
    private let stars: [Star] = (0..<40).map { _ in
        Star(x: .random(in: 0...1), y: .random(in: 0...1),
             size: .random(in: 1...2.5), opacity: .random(in: 0.12...0.65))
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
