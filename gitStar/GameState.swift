//
//  GameState.swift
//  gitStar
//

import SwiftUI

// MARK: - Git の内部状態
@Observable
class GitState {
    var isInitialized: Bool = false
    var workingFiles: [GitFile] = []
    var stagedFiles: [GitFile] = []
    var commits: [GitCommit] = []
    var remoteName: String? = nil
    var pushedCount: Int = 0

    struct GitFile: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var status: FileStatus

        enum FileStatus { case modified, new, deleted }
    }

    struct GitCommit: Identifiable {
        let id = UUID()
        var hash: String
        var message: String
    }

    func apply(command: String) -> CommandResult {
        let cmd = command.trimmingCharacters(in: .whitespaces)

        if cmd == "git init" {
            isInitialized = true
            workingFiles = [.init(name: "map.txt", status: .new)]
            return .success("✨ .git が生まれた！記録の旅、スタート！")
        }

        if cmd == "git status" {
            return .info(statusText())
        }

        if cmd.hasPrefix("git add") {
            let target = cmd.replacingOccurrences(of: "git add", with: "").trimmingCharacters(in: .whitespaces)
            let matched = workingFiles.filter { target == "." || target == $0.name }
            if matched.isEmpty { return .failure("そのファイルは見当たらないよ…") }
            stagedFiles.append(contentsOf: matched)
            workingFiles.removeAll { f in matched.contains(where: { $0.id == f.id }) }
            return .success("📦 \(matched.map(\.name).joined(separator: ", ")) を宅配ボックスに入れた！")
        }

        if cmd.hasPrefix("git commit") {
            if stagedFiles.isEmpty { return .failure("宅配ボックスが空っぽ…\ngit add してからにしよう！") }
            let msgMatch = cmd.range(of: #"(?<=-m\s")[^"]*"#, options: .regularExpression)
            let message = msgMatch.map { String(cmd[$0]) } ?? "no message"
            let hash = String(UUID().uuidString.prefix(7).lowercased())
            commits.append(.init(hash: hash, message: message))
            stagedFiles.removeAll()
            return .success("🏛 コミット完了！\n[\(hash)] \(message)")
        }

        if cmd.hasPrefix("git log") {
            if commits.isEmpty { return .info("まだコミットはないよ。") }
            let log = commits.reversed().map { "● [\($0.hash)] \($0.message)" }.joined(separator: "\n")
            return .info(log)
        }

        if cmd.hasPrefix("git remote add") {
            remoteName = "origin"
            return .success("🌐 リモート（隣村）と繋がった！")
        }

        if cmd == "git push" || cmd == "git push origin main" {
            guard remoteName != nil else { return .failure("まだリモートが設定されてないよ。\ngit remote add origin <URL> からだ！") }
            pushedCount = commits.count
            return .success("🚀 push 完了！隣村に届いた！")
        }

        return .failure("うーん、そのコマンドはまだ知らないな…\nヒント: git で始めてみよう！")
    }

    private func statusText() -> String {
        var lines: [String] = []
        if !workingFiles.isEmpty {
            lines.append("📝 変更あり（未 add）:")
            lines.append(contentsOf: workingFiles.map { "  \($0.name)" })
        }
        if !stagedFiles.isEmpty {
            lines.append("📦 add 済み（未 commit）:")
            lines.append(contentsOf: stagedFiles.map { "  \($0.name)" })
        }
        if workingFiles.isEmpty && stagedFiles.isEmpty {
            lines.append("✅ 変更なし、クリーンな状態！")
        }
        return lines.joined(separator: "\n")
    }
}

enum CommandResult {
    case success(String)
    case failure(String)
    case info(String)

    var message: String {
        switch self { case .success(let m), .failure(let m), .info(let m): return m }
    }
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

// MARK: - ゲーム進行モード
enum GameMode {
    case story       // ダイアログを読む
    case mission     // コマンドを入力する
    case result      // 結果フィードバック
}

// MARK: - ミッション定義
struct Mission {
    let prompt: String
    let hint: String
    let validate: (String) -> Bool
    let successLine: DialogueLine
    let failLine: DialogueLine
}
