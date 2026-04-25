//
//  GameState.swift
//  gitStar
//

import SwiftUI

// MARK: - アニメーション対象エリア
enum GitArea: String {
    case working, staging, repo, remote
}

// MARK: - Git の内部状態
@Observable
class GitState {
    var isInitialized: Bool = false
    var workingFiles: [GitFile] = []
    var stagedFiles: [GitFile] = []
    var commits: [GitCommit] = []
    var remoteName: String? = nil
    var pushedCount: Int = 0
    var currentBranch: String = "main"
    var branches: [String] = ["main"]
    var lastPulsedArea: GitArea? = nil   // 街UIアニメーション用

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
        var branch: String
    }

    // MARK: コマンド実行
    func apply(command: String) -> CommandResult {
        let cmd = command.trimmingCharacters(in: .whitespaces)
        lastPulsedArea = nil

        // git init
        if cmd == "git init" {
            isInitialized = true
            branches = ["main"]
            currentBranch = "main"
            workingFiles = [.init(name: "map.txt", status: .new)]
            pulse(.working)
            return .success("✨ .git が生まれた！記録の旅、スタート！")
        }

        // git status
        if cmd == "git status" {
            return .info(statusText())
        }

        // git add
        if cmd.hasPrefix("git add") {
            let target = cmd
                .replacingOccurrences(of: "git add", with: "")
                .trimmingCharacters(in: .whitespaces)
            let matched = workingFiles.filter { target == "." || target == $0.name }
            if matched.isEmpty { return .failure("そのファイルは見当たらないよ…\nまず git status で確認しよう！") }
            stagedFiles.append(contentsOf: matched)
            workingFiles.removeAll { f in matched.contains { $0.id == f.id } }
            pulse(.staging)
            return .success("📦 \(matched.map(\.name).joined(separator: ", ")) を宅配ボックスに入れた！")
        }

        // git commit
        if cmd.hasPrefix("git commit") {
            if stagedFiles.isEmpty {
                return .failure("宅配ボックスが空っぽ…\ngit add してからにしよう！")
            }
            let msgMatch = cmd.range(of: #"(?<=-m\s")[^"]*"#, options: .regularExpression)
            let message = msgMatch.map { String(cmd[$0]) } ?? "no message"
            let hash = String(UUID().uuidString.prefix(7).lowercased())
            commits.append(.init(hash: hash, message: message, branch: currentBranch))
            stagedFiles.removeAll()
            pulse(.repo)
            return .success("🏛 コミット完了！\n[\(hash)] \(message)")
        }

        // git log
        if cmd.hasPrefix("git log") {
            if commits.isEmpty { return .info("まだコミットはないよ。\ngit commit してみよう！") }
            let oneline = cmd.contains("--oneline")
            let log = commits.reversed().map { c in
                oneline ? "[\(c.hash)] \(c.message)" : "● [\(c.hash)]\n  \(c.message) (\(c.branch))"
            }.joined(separator: "\n")
            return .info(log)
        }

        // git remote add
        if cmd.hasPrefix("git remote add") {
            remoteName = "origin"
            pulse(.remote)
            return .success("🌐 リモート（隣村）と繋がった！\nこれで push できるよ！")
        }

        // git push
        if cmd == "git push" || cmd.hasPrefix("git push origin") {
            guard remoteName != nil else {
                return .failure("まだリモートが設定されてないよ。\ngit remote add origin <URL> からだ！")
            }
            pushedCount = commits.count
            pulse(.remote)
            return .success("🚀 push 完了！隣村に届いた！")
        }

        // git pull
        if cmd == "git pull" || cmd.hasPrefix("git pull") {
            guard remoteName != nil else {
                return .failure("リモートがまだ設定されてないよ！")
            }
            pulse(.working)
            return .success("⬇️ pull 完了！\n隣村から最新の記録を受け取ったよ！")
        }

        // git branch
        if cmd.hasPrefix("git branch") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            if parts.count == 2 {
                // ブランチ一覧
                let list = branches.map { ($0 == currentBranch ? "* " : "  ") + $0 }.joined(separator: "\n")
                return .info(list)
            }
            if parts.count >= 3 {
                let newBranch = parts[2]
                if branches.contains(newBranch) {
                    return .failure("そのブランチは既にあるよ！")
                }
                branches.append(newBranch)
                pulse(.repo)
                return .success("🌿 ブランチ「\(newBranch)」を作ったよ！\nまだ今のブランチにいるから\ngit checkout で移動してね！")
            }
        }

        // git checkout / git switch
        if cmd.hasPrefix("git checkout") || cmd.hasPrefix("git switch") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            // -b オプション（作成＆移動）
            if parts.contains("-b") {
                let newBranch = parts.last ?? ""
                if !branches.contains(newBranch) { branches.append(newBranch) }
                currentBranch = newBranch
                pulse(.repo)
                return .success("🌿 ブランチ「\(newBranch)」を作って移動したよ！")
            }
            let target = parts.last ?? ""
            if branches.contains(target) {
                currentBranch = target
                // ブランチ切り替え時にworking/stagingをシミュレート
                if target != "main" && workingFiles.isEmpty {
                    workingFiles = [.init(name: "\(target).txt", status: .new)]
                }
                pulse(.repo)
                return .success("✅ 「\(target)」ブランチに移動したよ！")
            }
            return .failure("ブランチ「\(target)」は見つからないよ。\ngit branch で一覧を確認してみよう！")
        }

        // git merge
        if cmd.hasPrefix("git merge") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            let target = parts.count >= 3 ? parts[2] : ""
            guard branches.contains(target) else {
                return .failure("ブランチ「\(target)」は見つからないよ。")
            }
            // シンプルな fast-forward マージをシミュレート
            pulse(.repo)
            return .success("🔀 「\(target)」を「\(currentBranch)」にマージしたよ！\n歴史が1本につながった！")
        }

        // git diff
        if cmd.hasPrefix("git diff") {
            if workingFiles.isEmpty && stagedFiles.isEmpty {
                return .info("差分なし！クリーンな状態だよ。")
            }
            let changes = (workingFiles + stagedFiles).map { "+ \($0.name): 変更あり" }.joined(separator: "\n")
            return .info(changes)
        }

        // git stash
        if cmd == "git stash" {
            guard !workingFiles.isEmpty else {
                return .info("stash するものがないよ！")
            }
            workingFiles.removeAll()
            return .success("📎 作業を一時退避したよ！\ngit stash pop で戻せるよ。")
        }

        if cmd == "git stash pop" {
            workingFiles = [.init(name: "stashed.txt", status: .modified)]
            pulse(.working)
            return .success("📎 退避した作業を戻したよ！")
        }

        // git revert
        if cmd.hasPrefix("git revert") {
            guard !commits.isEmpty else {
                return .failure("まだコミットがないよ。")
            }
            let target = commits.last!
            let hash = String(UUID().uuidString.prefix(7).lowercased())
            commits.append(.init(hash: hash, message: "Revert \"\(target.message)\"", branch: currentBranch))
            pulse(.repo)
            return .success("↩️ revert 完了！\n[\(hash)] Revert \"\(target.message)\"\n\n歴史を消さずに「打ち消し」コミットを追加したよ！\n安全な戻し方だ。")
        }

        // git reset
        if cmd.hasPrefix("git reset") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            let mode = parts.contains("--hard") ? "hard"
                     : parts.contains("--soft") ? "soft" : "mixed"
            guard commits.count > 1 else {
                return .failure("戻れるコミットがないよ！")
            }
            let removed = commits.removeLast()
            switch mode {
            case "hard":
                workingFiles.removeAll()
                stagedFiles.removeAll()
                pulse(.repo)
                return .success("💥 reset --hard 完了！\n[\(removed.hash)] を完全に削除。\n作業内容も消えたよ。\n\n⚠️ やり直しは reflog からしかできない！")
            case "soft":
                stagedFiles = [.init(name: removed.message + ".txt", status: .modified)]
                pulse(.repo)
                return .success("🔵 reset --soft 完了！\nコミットを取り消して\n変更を Staging に残したよ。")
            default:
                workingFiles = [.init(name: removed.message + ".txt", status: .modified)]
                pulse(.repo)
                return .success("🟡 reset --mixed 完了！\nコミットを取り消して\n変更を Working に残したよ。")
            }
        }

        // git reflog
        if cmd == "git reflog" {
            let log = commits.enumerated().reversed().map {
                "[\($0.element.hash)] HEAD@{\($0.offset)}: commit: \($0.element.message)"
            }.joined(separator: "\n")
            let header = "🔍 reflog — 消えた記録も残ってる！\n"
            return .info(header + (log.isEmpty ? "(まだ何もないよ)" : log))
        }

        // git cherry-pick
        if cmd.hasPrefix("git cherry-pick") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            let hash = parts.count >= 3 ? parts[2] : ""
            if let target = commits.first(where: { $0.hash.hasPrefix(hash) || $0.hash == hash }) {
                let newHash = String(UUID().uuidString.prefix(7).lowercased())
                commits.append(.init(hash: newHash, message: target.message, branch: currentBranch))
                pulse(.repo)
                return .success("🍒 cherry-pick 完了！\n[\(target.hash)] \(target.message)\nを現在のブランチに取り込んだよ！")
            }
            // ハッシュが見つからなくてもデモ用に成功させる
            let newHash = String(UUID().uuidString.prefix(7).lowercased())
            commits.append(.init(hash: newHash, message: "cherry-picked commit", branch: currentBranch))
            pulse(.repo)
            return .success("🍒 cherry-pick 完了！\n指定したコミットだけをつまみ食いしたよ！")
        }

        // git rebase
        if cmd.hasPrefix("git rebase") {
            pulse(.repo)
            if cmd.contains("-i") {
                return .success("✏️ git rebase -i 起動！\nコミット履歴を対話的に整理できるよ。\n\npick / squash / reword などで\n歴史を美しく整えよう！")
            }
            return .success("📐 rebase 完了！\nブランチの起点を付け替えて\n歴史を一直線に整えたよ！")
        }

        // git tag
        if cmd.hasPrefix("git tag") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            if parts.count == 1 {
                return .info("タグ一覧: (まだタグはないよ)")
            }
            let tagName = parts[1]
            pulse(.repo)
            return .success("🏷️ タグ「\(tagName)」を作ったよ！\nリリースのマーカーとして使えるんだ。\n\n`git push origin \(tagName)` で\nリモートにも送れるよ！")
        }

        // git blame
        if cmd.hasPrefix("git blame") {
            let parts = cmd.components(separatedBy: " ").filter { !$0.isEmpty }
            let file = parts.count >= 3 ? parts[2] : "map.txt"
            let lines = commits.suffix(3).map {
                "[\($0.hash)] (\($0.branch)) \($0.message)"
            }.joined(separator: "\n")
            return .info("🕵️ \(file) の行ごとの変更者:\n\n\(lines.isEmpty ? "(コミットがまだないよ)" : lines)")
        }

        // git bisect
        if cmd.hasPrefix("git bisect") {
            let sub = cmd.components(separatedBy: " ").dropFirst().first ?? ""
            switch sub {
            case "start":
                return .info("🔍 bisect 開始！\n`git bisect bad` で今のコミットをバグありに\n`git bisect good <hash>` で正常なコミットを指定してね。")
            case "bad":
                return .info("❌ このコミットをバグありとマークしたよ。\n次は正常なコミットを `git bisect good <hash>` で指定して！")
            case "good":
                return .info("✅ 正常なコミットをマークしたよ。\nGit が二分探索でバグの場所を絞り込むよ！")
            case "reset":
                return .success("🔍 bisect 終了！\nバグを特定できたね。お疲れさま！")
            default:
                return .info("git bisect start から始めよう！")
            }
        }

        // git log 高度な使い方
        if cmd.hasPrefix("git log") {
            if commits.isEmpty { return .info("まだコミットはないよ。") }
            let log = commits.reversed().map { "[\($0.hash)] \($0.message) (\($0.branch))" }.joined(separator: "\n")
            return .info(log)
        }

        // .gitignore
        if cmd == "touch .gitignore" || cmd.hasPrefix("echo") && cmd.contains(".gitignore") {
            workingFiles.append(.init(name: ".gitignore", status: .new))
            pulse(.working)
            return .success("📄 .gitignore を作ったよ！\nここに書いたファイルは\nGit が無視してくれる。\n\n例: node_modules/ .env .DS_Store")
        }

        return .failure("うーん、そのコマンドはまだ知らないな…\nヒント: git で始めてみよう！")
    }

    private func pulse(_ area: GitArea) {
        lastPulsedArea = area
    }

    private func statusText() -> String {
        var lines = ["On branch \(currentBranch)"]
        if !workingFiles.isEmpty {
            lines.append("\n📝 変更あり（未 add）:")
            lines.append(contentsOf: workingFiles.map { "  modified: \($0.name)" })
        }
        if !stagedFiles.isEmpty {
            lines.append("\n📦 add 済み（未 commit）:")
            lines.append(contentsOf: stagedFiles.map { "  new file: \($0.name)" })
        }
        if workingFiles.isEmpty && stagedFiles.isEmpty {
            lines.append("nothing to commit, working tree clean ✅")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - コマンド結果
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

// MARK: - ゲームモード
enum GameMode: Equatable {
    case story
    case mission
    case result
    case arcComplete
}

// MARK: - ミッション定義
struct Mission {
    let prompt: String
    let hint: String
    let validate: (String) -> Bool
    let successLine: DialogueLine
    let failLine: DialogueLine
}
