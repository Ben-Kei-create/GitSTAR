//
//  BackgroundArtworks.swift
//  gitStar
//
//  各 Arc の背景アートワーク（仮実装）。
//  WorldHealth と WorldMood に応答して見た目が変化する。
//  将来 Image 差し替え可能な設計。
//

import SwiftUI

// ════════════════════════════════════════════════════════
// MARK: - Arc 1：廃墟の村
// ════════════════════════════════════════════════════════

struct RuinedVillageBG: BackgroundArtwork {
    let sceneID = "ruined_village"
    func makeView(health: WorldHealth, mood: WorldMood) -> AnyView {
        AnyView(RuinedVillageView(health: health.value, mood: mood))
    }
}

private struct RuinedVillageView: View {
    let health: Double
    let mood: WorldMood

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sky gradient (gradually warmer with health)
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.05, blue: 0.13),
                        Color(red: 0.10 + health * 0.08,
                              green: 0.08 + health * 0.05,
                              blue: 0.20 + health * 0.04)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Distant mountains silhouette
                Path { p in
                    let w = geo.size.width
                    let baseY = geo.size.height * 0.72
                    p.move(to: CGPoint(x: 0, y: baseY))
                    p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 30))
                    p.addLine(to: CGPoint(x: w * 0.32, y: baseY - 12))
                    p.addLine(to: CGPoint(x: w * 0.50, y: baseY - 38))
                    p.addLine(to: CGPoint(x: w * 0.72, y: baseY - 18))
                    p.addLine(to: CGPoint(x: w * 0.88, y: baseY - 32))
                    p.addLine(to: CGPoint(x: w, y: baseY - 8))
                    p.addLine(to: CGPoint(x: w, y: geo.size.height))
                    p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.05, green: 0.06, blue: 0.12).opacity(0.85))

                // Ruined houses (close foreground)
                Path { p in
                    let w = geo.size.width
                    let baseY = geo.size.height * 0.85
                    // House 1 (broken)
                    p.move(to: CGPoint(x: w * 0.10, y: baseY))
                    p.addLine(to: CGPoint(x: w * 0.10, y: baseY - 28))
                    p.addLine(to: CGPoint(x: w * 0.16, y: baseY - 38))
                    p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 28))
                    p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 22))   // broken roof
                    p.addLine(to: CGPoint(x: w * 0.22, y: baseY - 26))
                    p.addLine(to: CGPoint(x: w * 0.22, y: baseY))
                    p.closeSubpath()
                    // House 2
                    p.move(to: CGPoint(x: w * 0.62, y: baseY))
                    p.addLine(to: CGPoint(x: w * 0.62, y: baseY - 22))
                    p.addLine(to: CGPoint(x: w * 0.72, y: baseY - 32))
                    p.addLine(to: CGPoint(x: w * 0.82, y: baseY - 22))
                    p.addLine(to: CGPoint(x: w * 0.82, y: baseY))
                    p.closeSubpath()
                }
                .fill(Color.black.opacity(0.7))

                // Faint distant lights (more with health)
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Color(red: 0.95, green: 0.75, blue: 0.45)
                            .opacity(0.0 + health * Double.random(in: 0.4...0.9)))
                        .frame(width: 2.5, height: 2.5)
                        .blur(radius: 1.0)
                        .position(
                            x: geo.size.width * (0.1 + 0.1 * Double(i)),
                            y: geo.size.height * (0.7 + Double(i % 3) * 0.04)
                        )
                }
            }
            .modifier(MoodOverlay(mood: mood, health: health))
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Arc 2：合流地点
// ════════════════════════════════════════════════════════

struct JunctionBG: BackgroundArtwork {
    let sceneID = "junction"
    func makeView(health: WorldHealth, mood: WorldMood) -> AnyView {
        AnyView(JunctionView(health: health.value, mood: mood))
    }
}

private struct JunctionView: View {
    let health: Double
    let mood: WorldMood

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Twilight gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.08, blue: 0.20),
                        Color(red: 0.18, green: 0.12, blue: 0.28)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Two converging paths (light streaks)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: geo.size.height))
                    p.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.5))
                    p.move(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    p.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.5))
                }
                .stroke(
                    Color(red: 0.55, green: 0.85, blue: 1.0).opacity(0.18 + health * 0.15),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .blur(radius: 2)

                // Hill silhouette
                Path { p in
                    let w = geo.size.width
                    let baseY = geo.size.height * 0.78
                    p.move(to: CGPoint(x: 0, y: baseY))
                    p.addQuadCurve(to: CGPoint(x: w, y: baseY),
                                   control: CGPoint(x: w / 2, y: baseY - 50))
                    p.addLine(to: CGPoint(x: w, y: geo.size.height))
                    p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.04, green: 0.06, blue: 0.12).opacity(0.9))
            }
            .modifier(MoodOverlay(mood: mood, health: health))
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Arc 3：嵐
// ════════════════════════════════════════════════════════

struct StormBG: BackgroundArtwork {
    let sceneID = "storm"
    func makeView(health: WorldHealth, mood: WorldMood) -> AnyView {
        AnyView(StormView(health: health.value, mood: mood))
    }
}

private struct StormView: View {
    let health: Double
    let mood: WorldMood
    @State private var lightningOpacity: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Storm gradient (heavier at top)
                LinearGradient(
                    colors: [
                        Color(red: 0.18, green: 0.07, blue: 0.10),
                        Color(red: 0.08, green: 0.04, blue: 0.10)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Heavy clouds
                ForEach(0..<5, id: \.self) { i in
                    Ellipse()
                        .fill(Color.black.opacity(0.4))
                        .frame(
                            width: geo.size.width * 0.4,
                            height: 35 + CGFloat(i) * 4
                        )
                        .blur(radius: 16)
                        .offset(
                            x: CGFloat(i % 2 == 0 ? -40 : 40),
                            y: CGFloat(-geo.size.height * 0.4 + CGFloat(i) * 18)
                        )
                }

                // Lightning flash
                Color.white
                    .opacity(lightningOpacity)

                // Foreground (ground)
                Rectangle()
                    .fill(Color(red: 0.04, green: 0.03, blue: 0.06))
                    .frame(height: geo.size.height * 0.18)
                    .position(x: geo.size.width / 2, y: geo.size.height - geo.size.height * 0.09)
            }
            .modifier(MoodOverlay(mood: mood, health: health))
            .onAppear {
                triggerLightning()
            }
        }
    }

    private func triggerLightning() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 4...8), repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.05)) { lightningOpacity = 0.18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.3)) { lightningOpacity = 0 }
            }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Arc 4：深夜の危機
// ════════════════════════════════════════════════════════

struct MidnightCrisisBG: BackgroundArtwork {
    let sceneID = "midnight_crisis"
    func makeView(health: WorldHealth, mood: WorldMood) -> AnyView {
        AnyView(MidnightCrisisView(health: health.value, mood: mood))
    }
}

private struct MidnightCrisisView: View {
    let health: Double
    let mood: WorldMood
    @State private var glitchY: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep void
                Color(red: 0.02, green: 0.02, blue: 0.05)

                // Falling glitch lines
                TimelineView(.periodic(from: .now, by: 0.3)) { _ in
                    Canvas { ctx, size in
                        for _ in 0..<8 {
                            let y = CGFloat.random(in: 0...size.height)
                            let w = CGFloat.random(in: 30...160)
                            let x = CGFloat.random(in: 0...size.width - w)
                            let rect = CGRect(x: x, y: y, width: w, height: 0.7)
                            ctx.fill(
                                Path(rect),
                                with: .color(Color(red: 0.45, green: 0.55, blue: 0.85).opacity(0.4))
                            )
                        }
                    }
                }
                .blur(radius: 0.4)

                // Pulsing red core (gc warning)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.85, green: 0.10, blue: 0.20).opacity(0.18),
                                .clear
                            ],
                            center: .center, startRadius: 5, endRadius: 80
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.25)
                    .modifier(Flicker(intensity: 0.5))
            }
            .modifier(MoodOverlay(mood: mood, health: health))
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Arc 5：山奥の隠れ家
// ════════════════════════════════════════════════════════

struct MountainHermitBG: BackgroundArtwork {
    let sceneID = "mountain_hermit"
    func makeView(health: WorldHealth, mood: WorldMood) -> AnyView {
        AnyView(MountainHermitView(health: health.value, mood: mood))
    }
}

private struct MountainHermitView: View {
    let health: Double
    let mood: WorldMood

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Calm purple-blue
                LinearGradient(
                    colors: [
                        Color(red: 0.10, green: 0.10, blue: 0.22),
                        Color(red: 0.18, green: 0.16, blue: 0.30)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Layered mountains
                ForEach(0..<3, id: \.self) { i in
                    let alpha = 0.35 + Double(i) * 0.2
                    let yBase = geo.size.height * (0.5 + Double(i) * 0.13)
                    Path { p in
                        let w = geo.size.width
                        p.move(to: CGPoint(x: 0, y: yBase))
                        p.addLine(to: CGPoint(x: w * 0.25, y: yBase - 50))
                        p.addLine(to: CGPoint(x: w * 0.5, y: yBase - 20))
                        p.addLine(to: CGPoint(x: w * 0.75, y: yBase - 60))
                        p.addLine(to: CGPoint(x: w, y: yBase - 30))
                        p.addLine(to: CGPoint(x: w, y: geo.size.height))
                        p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                        p.closeSubpath()
                    }
                    .fill(Color(red: 0.05, green: 0.06, blue: 0.14).opacity(alpha))
                }

                // Distant temple light
                Circle()
                    .fill(Color(red: 1.0, green: 0.85, blue: 0.55).opacity(0.5 + health * 0.3))
                    .frame(width: 6, height: 6)
                    .blur(radius: 3)
                    .position(x: geo.size.width * 0.7, y: geo.size.height * 0.55)
            }
            .modifier(MoodOverlay(mood: mood, health: health))
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Arc 6：再生の夜空
// ════════════════════════════════════════════════════════

struct RebornNightBG: BackgroundArtwork {
    let sceneID = "reborn_night"
    func makeView(health: WorldHealth, mood: WorldMood) -> AnyView {
        AnyView(RebornNightView(health: health.value, mood: mood))
    }
}

private struct RebornNightView: View {
    let health: Double
    let mood: WorldMood

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Vibrant night gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.08, blue: 0.22),
                        Color(red: 0.18, green: 0.10, blue: 0.30),
                        Color(red: 0.08, green: 0.06, blue: 0.18)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Aurora-like glow
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.45, green: 0.85, blue: 1.0).opacity(0.25),
                                .clear
                            ],
                            center: .center, startRadius: 10, endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 200)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.4)
                    .blur(radius: 30)

                // The new tree (silhouette + glow)
                Path { p in
                    let w = geo.size.width
                    let h = geo.size.height
                    p.move(to: CGPoint(x: w / 2, y: h))
                    p.addLine(to: CGPoint(x: w / 2 - 2, y: h * 0.55))
                    // Branches
                    p.addLine(to: CGPoint(x: w / 2 - 50, y: h * 0.4))
                    p.move(to: CGPoint(x: w / 2 - 2, y: h * 0.55))
                    p.addLine(to: CGPoint(x: w / 2 + 50, y: h * 0.4))
                    p.move(to: CGPoint(x: w / 2 - 2, y: h * 0.45))
                    p.addLine(to: CGPoint(x: w / 2 - 30, y: h * 0.30))
                    p.move(to: CGPoint(x: w / 2 - 2, y: h * 0.45))
                    p.addLine(to: CGPoint(x: w / 2 + 30, y: h * 0.30))
                }
                .stroke(
                    Color(red: 0.85, green: 0.95, blue: 1.0).opacity(0.4),
                    style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
                )
                .shadow(color: Color(red: 0.55, green: 0.85, blue: 1.0).opacity(0.6), radius: 8)
            }
            .modifier(MoodOverlay(mood: mood, health: health))
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - ムードオーバーレイ（共通）
// ════════════════════════════════════════════════════════

private struct MoodOverlay: ViewModifier {
    let mood: WorldMood
    let health: Double

    func body(content: Content) -> some View {
        let despairAmount = max(0, 1 - health)

        content
            .overlay {
                switch mood {
                case .despair, .crisis:
                    Color.black.opacity(despairAmount * 0.25)
                        .allowsHitTesting(false)
                case .hope, .climax:
                    Color(red: 1.0, green: 0.95, blue: 0.8)
                        .opacity(0.04)
                        .allowsHitTesting(false)
                case .tension:
                    Color(red: 1.0, green: 0.5, blue: 0.5)
                        .opacity(0.04)
                        .allowsHitTesting(false)
                case .calm:
                    Color.clear
                }
            }
            .modifier(NoiseOverlay(intensity: despairAmount * 0.35))
    }
}
