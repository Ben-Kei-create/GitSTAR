//
//  WorldVisuals.swift
//  gitStar
//
//  世界観ビジュアルの基盤レイヤー：
//  - キャラクター・背景の差し替え可能な Protocol
//  - ノイズ / フリッカー / グリッチの ViewModifier
//  - Git フロー図の「うっすら背景表示」レイヤー
//

import SwiftUI

// ════════════════════════════════════════════════════════
// MARK: - 世界の状態
// ════════════════════════════════════════════════════════

/// 世界の修復進捗（0.0 = 完全崩壊、1.0 = 完全実体化）
struct WorldHealth: Equatable {
    var value: Double

    static let initial = WorldHealth(value: 0.05)
    static let arc1End = WorldHealth(value: 0.15)
    static let arc2End = WorldHealth(value: 0.30)
    static let arc3End = WorldHealth(value: 0.45)
    static let arc4End = WorldHealth(value: 0.65)
    static let arc5End = WorldHealth(value: 0.85)
    static let arc6End = WorldHealth(value: 1.00)

    /// Arc番号 → 推定 health
    static func forArc(_ n: Int, episodeProgress: Double = 0) -> WorldHealth {
        let base: Double = [0.05, 0.15, 0.30, 0.45, 0.65, 0.85][min(max(n - 1, 0), 5)]
        let next: Double = [0.15, 0.30, 0.45, 0.65, 0.85, 1.00][min(max(n - 1, 0), 5)]
        return .init(value: base + (next - base) * min(max(episodeProgress, 0), 1))
    }
}

/// 演出のムード（背景が反応する）
enum WorldMood {
    case despair      // 絶望（暗い、ノイズ強）
    case hope         // 希望（やわらかい光）
    case tension      // 緊張（震える、点滅）
    case calm         // 静謐（落ち着いた色）
    case climax       // 山場（激しい光）
    case crisis       // 危機（漆黒、グリッチ）
}

/// キャラクターの解像度（消えかけ → 実体化）
struct CharacterResolution: Equatable {
    var value: Double  // 0.0 = 消えかけ、1.0 = 完全実体化

    static let fading    = CharacterResolution(value: 0.20)
    static let appearing = CharacterResolution(value: 0.45)
    static let stable    = CharacterResolution(value: 0.75)
    static let solid     = CharacterResolution(value: 1.00)
}

// ════════════════════════════════════════════════════════
// MARK: - 差し替え可能な抽象化
// ════════════════════════════════════════════════════════

/// キャラクター立ち絵（仮実装 → 本実装の Image 差し替え可能）
protocol CharacterArtwork {
    var characterID: String { get }
    var displayName: String { get }
    var primaryColor: Color { get }
    @MainActor func makeView(resolution: CharacterResolution) -> AnyView
}

/// 背景アートワーク（Arc・状況ごとに差し替え可能）
protocol BackgroundArtwork {
    var sceneID: String { get }
    @MainActor func makeView(health: WorldHealth, mood: WorldMood) -> AnyView
}

// ════════════════════════════════════════════════════════
// MARK: - ビジュアルエフェクト
// ════════════════════════════════════════════════════════

/// ノイズオーバーレイ（消えかけ表現）
struct NoiseOverlay: ViewModifier {
    let intensity: Double  // 0.0 ~ 1.0

    func body(content: Content) -> some View {
        content.overlay(
            TimelineView(.periodic(from: .now, by: 0.09)) { _ in
                Canvas { ctx, size in
                    let count = Int(70 * intensity)
                    guard count > 0 else { return }
                    for _ in 0..<count {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let r = CGFloat.random(in: 0.6...1.4)
                        let a = Double.random(in: 0.05...0.22) * intensity
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                            with: .color(.white.opacity(a))
                        )
                    }
                }
                .allowsHitTesting(false)
            }
        )
    }
}

extension View {
    func worldNoise(intensity: Double = 0.5) -> some View {
        modifier(NoiseOverlay(intensity: intensity))
    }
}

/// フリッカー（点滅）
struct Flicker: ViewModifier {
    let intensity: Double  // 発生確率

    func body(content: Content) -> some View {
        TimelineView(.periodic(from: .now, by: 0.12)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let glitch = (sin(t * 7) + sin(t * 13.3)) * 0.5
            let visible = glitch > -0.5 || Double.random(in: 0...1) > intensity
            content.opacity(visible ? 1.0 : (1.0 - intensity * 0.7))
        }
    }
}

extension View {
    func flicker(intensity: Double = 0.3) -> some View {
        modifier(Flicker(intensity: intensity))
    }
}

/// グリッチ（時折ずれる・色が乱れる）
struct Glitch: ViewModifier {
    let intensity: Double

    func body(content: Content) -> some View {
        TimelineView(.periodic(from: .now, by: 0.6)) { context in
            let trigger = Int(context.date.timeIntervalSinceReferenceDate * 1.6) % 7 == 0
            let active = trigger && Double.random(in: 0...1) < intensity
            content
                .offset(x: active ? CGFloat.random(in: -3...3) : 0)
                .hueRotation(.degrees(active ? Double.random(in: -8...8) : 0))
        }
    }
}

extension View {
    func worldGlitch(intensity: Double = 0.3) -> some View {
        modifier(Glitch(intensity: intensity))
    }
}

/// 解像度に応じた共通フェード（キャラ用ヘルパー）
extension View {
    func resolutionFade(_ resolution: Double) -> some View {
        self
            .opacity(0.4 + resolution * 0.55)
            .blur(radius: max(0, (1 - resolution) * 2.2))
            .modifier(NoiseOverlay(intensity: max(0, (1 - resolution) * 0.55)))
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Git フロー図のうっすら表示レイヤー
// ════════════════════════════════════════════════════════

/// 既存の VerticalGitGraph を「世界を支える根」として薄く全画面に敷く
/// プレイヤーのコミットが増えるほど、世界がしっかり支えられている感覚を視覚化
struct GhostFlowLayer: View {
    let git: GitState
    var baseOpacity: Double = 0.07
    @State private var pulse: Double = 0

    var body: some View {
        VerticalGitGraph(git: git)
            .opacity(baseOpacity + pulse * 0.04)
            .blur(radius: 1.4)
            .saturation(0.6)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    pulse = 1.0
                }
            }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - キャラクター/背景のレジストリ
// ════════════════════════════════════════════════════════

/// 物語で参照する Speaker と Artwork の対応
enum CharacterRegistry {
    static func artwork(for id: CharacterID) -> CharacterArtwork {
        switch id {
        case .komi:     return KomiArtwork()
        case .master:   return MasterArtwork()
        case .bran:     return BranArtwork()
        case .conflix:  return ConflixArtwork()
        case .rebay:    return RebayArtwork()
        case .logBaa:   return LogBaaArtwork()
        }
    }
}

enum BackgroundRegistry {
    static func backgroundForArc(_ n: Int) -> BackgroundArtwork {
        switch n {
        case 1: return RuinedVillageBG()
        case 2: return JunctionBG()
        case 3: return StormBG()
        case 4: return MidnightCrisisBG()
        case 5: return MountainHermitBG()
        case 6: return RebornNightBG()
        default: return RuinedVillageBG()
        }
    }
}
