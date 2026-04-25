//
//  CityStageView.swift
//  gitStar
//

import SwiftUI

struct CityStageView: View {
    let git: GitState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.gitStarBackground, .gitStarDeepBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            StarsView()

            VStack(spacing: 0) {
                // タイトル
                HStack {
                    Text("GitSTAR")
                        .font(.system(size: 20, weight: .thin, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(8)
                    Spacer()
                    Text("Arc 1")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.gitStarAccent.opacity(0.5))
                        .tracking(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // 4 エリア
                HStack(spacing: 10) {
                    GitAreaCard(
                        icon: "pencil",
                        label: "Working",
                        sublabel: "作業部屋",
                        color: Color(red: 0.6, green: 0.8, blue: 1.0),
                        count: git.workingFiles.count,
                        items: git.workingFiles.map(\.name),
                        isActive: !git.workingFiles.isEmpty
                    )

                    FlowArrow(label: "add")

                    GitAreaCard(
                        icon: "shippingbox",
                        label: "Staging",
                        sublabel: "宅配ボックス",
                        color: Color(red: 1.0, green: 0.85, blue: 0.5),
                        count: git.stagedFiles.count,
                        items: git.stagedFiles.map(\.name),
                        isActive: !git.stagedFiles.isEmpty
                    )

                    FlowArrow(label: "commit")

                    GitAreaCard(
                        icon: "building.columns",
                        label: "Repo",
                        sublabel: "役所",
                        color: Color(red: 0.6, green: 1.0, blue: 0.75),
                        count: git.commits.count,
                        items: git.commits.suffix(2).map { "[\($0.hash)]" },
                        isActive: !git.commits.isEmpty
                    )

                    FlowArrow(label: "push")

                    GitAreaCard(
                        icon: "network",
                        label: "Remote",
                        sublabel: "隣村",
                        color: Color(red: 0.85, green: 0.65, blue: 1.0),
                        count: git.pushedCount,
                        items: git.remoteName.map { [$0] } ?? [],
                        isActive: git.remoteName != nil
                    )
                }
                .padding(.horizontal, 16)

                Spacer()
            }
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

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isActive ? 0.12 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(isActive ? 0.5 : 0.15), lineWidth: 1)
                    )

                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(color.opacity(isActive ? 1.0 : 0.35))

                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(color)
                    }

                    // ファイル名小表示
                    ForEach(items.prefix(2), id: \.self) { item in
                        Text(item)
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundStyle(color.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(isActive ? 0.8 : 0.3))

            Text(sublabel)
                .font(.system(size: 9, weight: .light))
                .foregroundStyle(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.4), value: isActive)
        .animation(.easeInOut(duration: 0.4), value: count)
    }
}

// MARK: - 矢印
struct FlowArrow: View {
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .light))
                .foregroundStyle(.white.opacity(0.2))
            Text(label)
                .font(.system(size: 7, design: .monospaced))
                .foregroundStyle(.white.opacity(0.2))
        }
    }
}

// MARK: - 星空（位置固定版）
struct StarsView: View {
    private struct Star {
        let x, y, size: CGFloat
        let opacity: Double
    }
    private let stars: [Star] = (0..<40).map { _ in
        Star(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 1...2.5),
            opacity: Double.random(in: 0.15...0.7)
        )
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
