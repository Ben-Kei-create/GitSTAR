//
//  CharacterArtworks.swift
//  gitStar
//
//  キャラクター立ち絵の仮実装。
//  各 Artwork 構造体は CharacterArtwork に準拠。
//  将来 `Image("character_komi")` などに差し替えるだけで動く設計。
//

import SwiftUI

// ════════════════════════════════════════════════════════
// MARK: - コミ — .git に宿る記憶の精霊
// ════════════════════════════════════════════════════════

struct KomiArtwork: CharacterArtwork {
    let characterID  = "komi"
    let displayName  = "コミ"
    let primaryColor = Color(red: 0.72, green: 0.95, blue: 1.00)

    func makeView(resolution: CharacterResolution) -> AnyView {
        AnyView(KomiView(resolution: resolution.value))
    }
}

private struct KomiView: View {
    let resolution: Double
    @State private var floatY: CGFloat = 0
    @State private var glowAmt: Double = 0.5

    var body: some View {
        ZStack {
            // Outer aura
            Circle()
                .fill(Color(red: 0.72, green: 0.95, blue: 1.0).opacity(glowAmt * resolution * 0.45))
                .frame(width: 110, height: 110)
                .blur(radius: 22)

            // Body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.92, green: 0.99, blue: 1.0).opacity(0.95),
                            Color(red: 0.50, green: 0.85, blue: 1.0).opacity(0.65)
                        ],
                        center: .center, startRadius: 4, endRadius: 32
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.6), lineWidth: 1)
                )

            // Eyes
            HStack(spacing: 14) {
                Capsule().fill(Color.black.opacity(0.85)).frame(width: 4, height: 6)
                Capsule().fill(Color.black.opacity(0.85)).frame(width: 4, height: 6)
            }
            .offset(y: -3)

            // Smile
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addQuadCurve(to: CGPoint(x: 12, y: 0), control: CGPoint(x: 6, y: 5))
            }
            .stroke(Color.black.opacity(0.7), lineWidth: 1.4)
            .frame(width: 12, height: 6)
            .offset(y: 9)

            // Antenna wisp
            VStack(spacing: 1) {
                Capsule()
                    .fill(Color(red: 0.92, green: 0.99, blue: 1.0).opacity(0.7))
                    .frame(width: 1.8, height: 10)
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 4, height: 4)
                    .blur(radius: 0.4)
            }
            .offset(y: -36)
        }
        .frame(width: 120, height: 120)
        .offset(y: floatY)
        .resolutionFade(resolution)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) { floatY = -7 }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { glowAmt = 1.0 }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - マスター — 最後の記録者
// ════════════════════════════════════════════════════════

struct MasterArtwork: CharacterArtwork {
    let characterID  = "master"
    let displayName  = "マスター"
    let primaryColor = Color(red: 0.55, green: 0.50, blue: 0.78)

    func makeView(resolution: CharacterResolution) -> AnyView {
        AnyView(MasterView(resolution: resolution.value))
    }
}

private struct MasterView: View {
    let resolution: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            // Aura
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.55, green: 0.50, blue: 0.78).opacity(0.35), .clear],
                        center: .center, startRadius: 8, endRadius: 60
                    )
                )
                .frame(width: 110, height: 140)

            ZStack {
                // Cloak (trapezoidal)
                Path { p in
                    p.move(to: CGPoint(x: 14, y: 26))
                    p.addLine(to: CGPoint(x: 56, y: 26))
                    p.addLine(to: CGPoint(x: 70, y: 124))
                    p.addLine(to: CGPoint(x: 0, y: 124))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.14, blue: 0.28),
                            Color(red: 0.08, green: 0.06, blue: 0.18)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Hood
                Circle()
                    .fill(Color(red: 0.10, green: 0.08, blue: 0.22))
                    .frame(width: 38, height: 38)
                    .offset(x: 35, y: 6)

                // Hood shadow (face)
                Ellipse()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: 22, height: 14)
                    .offset(x: 35, y: 12)

                // Glowing eye
                Circle()
                    .fill(Color(red: 0.65, green: 0.85, blue: 1.0))
                    .frame(width: 3.5, height: 3.5)
                    .blur(radius: 0.6)
                    .offset(x: 35, y: 12)
                    .shadow(color: Color(red: 0.65, green: 0.85, blue: 1.0), radius: 4)

                // Staff
                Capsule()
                    .fill(Color(red: 0.45, green: 0.32, blue: 0.20))
                    .frame(width: 2.2, height: 110)
                    .offset(x: 70, y: 0)

                // Staff orb
                Circle()
                    .fill(Color(red: 0.85, green: 0.75, blue: 1.0).opacity(0.8))
                    .frame(width: 6, height: 6)
                    .blur(radius: 0.8)
                    .offset(x: 70, y: -56)
                    .shadow(color: Color(red: 0.85, green: 0.75, blue: 1.0).opacity(0.7), radius: 5)
            }
            .frame(width: 80, height: 130)
        }
        .frame(width: 110, height: 150)
        .resolutionFade(resolution)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - ブラン — 分岐の民
// ════════════════════════════════════════════════════════

struct BranArtwork: CharacterArtwork {
    let characterID  = "bran"
    let displayName  = "ブラン"
    let primaryColor = Color(red: 0.52, green: 0.92, blue: 0.65)

    func makeView(resolution: CharacterResolution) -> AnyView {
        AnyView(BranView(resolution: resolution.value))
    }
}

private struct BranView: View {
    let resolution: Double
    @State private var sway: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Aura
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.52, green: 0.92, blue: 0.65).opacity(0.30), .clear],
                        center: .center, startRadius: 5, endRadius: 50
                    )
                )
                .frame(width: 100, height: 130)

            ZStack {
                // Body (capsule)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.45, blue: 0.30),
                                Color(red: 0.10, green: 0.28, blue: 0.18)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 36, height: 75)
                    .offset(y: 30)

                // Head
                Circle()
                    .fill(Color(red: 0.92, green: 0.96, blue: 0.85))
                    .frame(width: 28, height: 28)
                    .offset(y: -8)

                // Branching antlers (left)
                Path { p in
                    p.move(to: CGPoint(x: 14, y: 18))
                    p.addLine(to: CGPoint(x: 0, y: 0))
                    p.move(to: CGPoint(x: 8, y: 10))
                    p.addLine(to: CGPoint(x: -2, y: 6))
                }
                .stroke(Color(red: 0.52, green: 0.92, blue: 0.65), lineWidth: 1.5)
                .frame(width: 20, height: 20)
                .offset(x: -16, y: -16)

                // Branching antlers (right)
                Path { p in
                    p.move(to: CGPoint(x: 6, y: 18))
                    p.addLine(to: CGPoint(x: 20, y: 0))
                    p.move(to: CGPoint(x: 12, y: 10))
                    p.addLine(to: CGPoint(x: 22, y: 6))
                }
                .stroke(Color(red: 0.52, green: 0.92, blue: 0.65), lineWidth: 1.5)
                .frame(width: 20, height: 20)
                .offset(x: 16, y: -16)

                // Eyes
                HStack(spacing: 10) {
                    Circle().fill(Color(red: 0.20, green: 0.55, blue: 0.30)).frame(width: 3, height: 3)
                    Circle().fill(Color(red: 0.20, green: 0.55, blue: 0.30)).frame(width: 3, height: 3)
                }
                .offset(y: -10)
            }
            .frame(width: 80, height: 120)
            .rotationEffect(.degrees(sway))
        }
        .frame(width: 100, height: 140)
        .resolutionFade(resolution)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                sway = 2.5
            }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - コンフリックス — 矛盾の擬人化
// ════════════════════════════════════════════════════════

struct ConflixArtwork: CharacterArtwork {
    let characterID  = "conflix"
    let displayName  = "コンフリックス"
    let primaryColor = Color(red: 0.95, green: 0.45, blue: 0.55)

    func makeView(resolution: CharacterResolution) -> AnyView {
        AnyView(ConflixView(resolution: resolution.value))
    }
}

private struct ConflixView: View {
    let resolution: Double
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Dark menacing aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.1, blue: 0.2).opacity(0.4),
                            .clear
                        ],
                        center: .center, startRadius: 20, endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(pulse)

            // Two-toned split body
            HStack(spacing: 0) {
                // Left half (red truth)
                Path { p in
                    p.move(to: CGPoint(x: 50, y: 0))
                    p.addLine(to: CGPoint(x: 50, y: 130))
                    p.addLine(to: CGPoint(x: 10, y: 130))
                    p.addQuadCurve(to: CGPoint(x: 0, y: 65),
                                   control: CGPoint(x: 0, y: 100))
                    p.addQuadCurve(to: CGPoint(x: 50, y: 0),
                                   control: CGPoint(x: 5, y: 5))
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.60, green: 0.10, blue: 0.20),
                            Color(red: 0.30, green: 0.05, blue: 0.10)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 50, height: 130)

                // Right half (blue truth)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: 0))
                    p.addLine(to: CGPoint(x: 0, y: 130))
                    p.addLine(to: CGPoint(x: 40, y: 130))
                    p.addQuadCurve(to: CGPoint(x: 50, y: 65),
                                   control: CGPoint(x: 50, y: 100))
                    p.addQuadCurve(to: CGPoint(x: 0, y: 0),
                                   control: CGPoint(x: 45, y: 5))
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.20, blue: 0.55),
                            Color(red: 0.05, green: 0.10, blue: 0.30)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 50, height: 130)
            }

            // Central crack (split line glow)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.0), Color.white.opacity(0.85), Color.white.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 1.5, height: 130)
                .blur(radius: 1.2)

            // Two glowing eyes (one red, one blue)
            HStack(spacing: 32) {
                Circle()
                    .fill(Color(red: 1.0, green: 0.4, blue: 0.5))
                    .frame(width: 5, height: 5)
                    .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.5), radius: 5)
                Circle()
                    .fill(Color(red: 0.4, green: 0.7, blue: 1.0))
                    .frame(width: 5, height: 5)
                    .shadow(color: Color(red: 0.4, green: 0.7, blue: 1.0), radius: 5)
            }
            .offset(y: -38)
        }
        .frame(width: 140, height: 160)
        .resolutionFade(resolution)
        .worldGlitch(intensity: 0.4)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = 1.08
            }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - リベイ — 時間の書き換え師
// ════════════════════════════════════════════════════════

struct RebayArtwork: CharacterArtwork {
    let characterID  = "rebay"
    let displayName  = "リベイ"
    let primaryColor = Color(red: 0.78, green: 0.65, blue: 1.00)

    func makeView(resolution: CharacterResolution) -> AnyView {
        AnyView(RebayView(resolution: resolution.value))
    }
}

private struct RebayView: View {
    let resolution: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.78, green: 0.65, blue: 1.0).opacity(0.32), .clear],
                        center: .center, startRadius: 5, endRadius: 55
                    )
                )
                .frame(width: 110, height: 140)

            ZStack {
                // Robe
                Path { p in
                    p.move(to: CGPoint(x: 18, y: 30))
                    p.addLine(to: CGPoint(x: 52, y: 30))
                    p.addLine(to: CGPoint(x: 64, y: 130))
                    p.addLine(to: CGPoint(x: 6, y: 130))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.30, green: 0.22, blue: 0.45),
                            Color(red: 0.18, green: 0.12, blue: 0.30)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Sash
                Rectangle()
                    .fill(Color(red: 0.78, green: 0.65, blue: 1.0).opacity(0.6))
                    .frame(width: 50, height: 4)
                    .offset(y: 30)

                // Head
                Circle()
                    .fill(Color(red: 0.92, green: 0.88, blue: 0.95))
                    .frame(width: 32, height: 32)
                    .offset(y: -22)

                // Eyes (closed, contemplative)
                HStack(spacing: 10) {
                    Capsule().fill(Color.black.opacity(0.7)).frame(width: 6, height: 1.5)
                    Capsule().fill(Color.black.opacity(0.7)).frame(width: 6, height: 1.5)
                }
                .offset(y: -22)

                // Measuring ruler
                Rectangle()
                    .fill(Color(red: 0.85, green: 0.75, blue: 0.55))
                    .frame(width: 4, height: 70)
                    .overlay(
                        VStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { _ in
                                Rectangle().fill(Color.black.opacity(0.4))
                                    .frame(width: 4, height: 1)
                            }
                        }
                    )
                    .offset(x: -42, y: 30)
                    .rotationEffect(.degrees(-8))
            }
            .frame(width: 100, height: 140)
        }
        .frame(width: 120, height: 150)
        .resolutionFade(resolution)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - ログバア — 記録の番人
// ════════════════════════════════════════════════════════

struct LogBaaArtwork: CharacterArtwork {
    let characterID  = "logBaa"
    let displayName  = "ログバア"
    let primaryColor = Color(red: 1.00, green: 0.85, blue: 0.45)

    func makeView(resolution: CharacterResolution) -> AnyView {
        AnyView(LogBaaView(resolution: resolution.value))
    }
}

private struct LogBaaView: View {
    let resolution: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.85, blue: 0.45).opacity(0.32), .clear],
                        center: .center, startRadius: 5, endRadius: 60
                    )
                )
                .frame(width: 120, height: 140)

            ZStack {
                // Robe (slightly hunched)
                Path { p in
                    p.move(to: CGPoint(x: 22, y: 38))
                    p.addLine(to: CGPoint(x: 58, y: 38))
                    p.addLine(to: CGPoint(x: 70, y: 130))
                    p.addLine(to: CGPoint(x: 10, y: 130))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.42, green: 0.32, blue: 0.20),
                            Color(red: 0.25, green: 0.18, blue: 0.10)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Hood
                Circle()
                    .fill(Color(red: 0.30, green: 0.22, blue: 0.14))
                    .frame(width: 38, height: 38)
                    .offset(y: -16)

                // White beard
                Path { p in
                    p.addEllipse(in: CGRect(x: 15, y: 0, width: 30, height: 30))
                }
                .fill(Color.white.opacity(0.85))
                .frame(width: 50, height: 30)
                .offset(y: 5)

                // Glowing wise eyes
                HStack(spacing: 11) {
                    Circle().fill(Color(red: 1.0, green: 0.9, blue: 0.55)).frame(width: 3.5, height: 3.5)
                        .shadow(color: Color(red: 1.0, green: 0.9, blue: 0.55), radius: 3)
                    Circle().fill(Color(red: 1.0, green: 0.9, blue: 0.55)).frame(width: 3.5, height: 3.5)
                        .shadow(color: Color(red: 1.0, green: 0.9, blue: 0.55), radius: 3)
                }
                .offset(y: -14)

                // Scroll
                ZStack {
                    Capsule()
                        .fill(Color(red: 0.95, green: 0.88, blue: 0.65))
                        .frame(width: 26, height: 9)
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 16, height: 1.2)
                        .offset(y: -1)
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 12, height: 1.2)
                        .offset(y: 1.5)
                }
                .offset(x: 28, y: 30)
                .rotationEffect(.degrees(15))
            }
            .frame(width: 90, height: 140)
        }
        .frame(width: 130, height: 150)
        .resolutionFade(resolution)
    }
}
