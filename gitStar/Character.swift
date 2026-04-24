//
//  Character.swift
//  gitStar
//

import SwiftUI

enum CharacterID: String {
    case master   // 村長
    case komi     // コミ（相棒）
    case bran     // ブラン
    case logBaa   // ログ婆
    case rebay    // リベイ
    case conflix  // コンフリ
}

struct Character {
    let id: CharacterID
    let name: String
    let symbol: String
    let tint: Color
    let shape: AvatarShape

    static func of(_ id: CharacterID) -> Character {
        switch id {
        case .master:
            return .init(id: .master, name: "村長", symbol: "mountain.2.fill",
                         tint: Color(red: 1.0, green: 0.82, blue: 0.42), shape: .hexagon)
        case .komi:
            return .init(id: .komi, name: "コミ", symbol: "sparkle",
                         tint: Color(red: 0.56, green: 0.85, blue: 1.00), shape: .circle)
        case .bran:
            return .init(id: .bran, name: "ブラン", symbol: "arrow.triangle.branch",
                         tint: Color(red: 0.52, green: 0.92, blue: 0.65), shape: .roundedSquare)
        case .logBaa:
            return .init(id: .logBaa, name: "ログ婆", symbol: "eye.fill",
                         tint: Color(red: 0.78, green: 0.62, blue: 1.00), shape: .diamond)
        case .rebay:
            return .init(id: .rebay, name: "リベイ", symbol: "arrow.triangle.2.circlepath",
                         tint: Color(red: 1.00, green: 0.45, blue: 0.48), shape: .hexagon)
        case .conflix:
            return .init(id: .conflix, name: "コンフリ", symbol: "exclamationmark.triangle.fill",
                         tint: Color(red: 1.00, green: 0.60, blue: 0.30), shape: .jagged)
        }
    }
}

enum AvatarShape {
    case circle, hexagon, roundedSquare, diamond, jagged
}

// MARK: - アバター表示
struct CharacterAvatar: View {
    let character: Character
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            shapeView
                .fill(character.tint.opacity(0.15))
                .overlay(
                    shapeView.stroke(character.tint.opacity(0.6), lineWidth: 1)
                )
            Image(systemName: character.symbol)
                .font(.system(size: size * 0.42, weight: .regular))
                .foregroundStyle(character.tint)
        }
        .frame(width: size, height: size)
    }

    private var shapeView: AnyShape {
        switch character.shape {
        case .circle:        AnyShape(Circle())
        case .hexagon:       AnyShape(HexagonShape())
        case .roundedSquare: AnyShape(RoundedRectangle(cornerRadius: size * 0.25))
        case .diamond:       AnyShape(DiamondShape())
        case .jagged:        AnyShape(JaggedShape())
        }
    }
}

// MARK: - カスタム図形
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2, cy = h / 2
        let r = min(w, h) / 2
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else      { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to:    CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct JaggedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let rOuter = min(rect.width, rect.height) / 2
        let rInner = rOuter * 0.7
        let points = 8
        for i in 0..<(points * 2) {
            let r = i % 2 == 0 ? rOuter : rInner
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else      { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}
