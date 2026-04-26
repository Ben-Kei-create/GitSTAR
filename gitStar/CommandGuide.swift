//
//  CommandGuide.swift
//  gitStar
//
//  Arc クリア後のコマンド復習カード用データ

import SwiftUI

struct CommandGuideEntry {
    let icon: String        // SF Symbol 名
    let what: String        // 一言説明（日本語）
    let example: String     // 使用例（改行あり）
    let tip: String         // 覚え方のコツ
    let color: Color        // アクセントカラー
}

enum CommandGuide {

    // コマンド文字列を正規化: "git add ." → "git add"
    static func normalizedKey(for cmd: String) -> String {
        let parts = cmd.trimmingCharacters(in: .whitespaces)
                       .components(separatedBy: " ")
                       .filter { !$0.isEmpty }
        if parts.first == "git", parts.count >= 2 {
            return "\(parts[0]) \(parts[1])"
        }
        // "touch .gitignore" など
        if parts.first == "touch" { return "touch .gitignore" }
        return parts.first ?? cmd
    }

    static func entry(for cmd: String) -> CommandGuideEntry? {
        let key = normalizedKey(for: cmd)
        return all[key] ?? all[cmd]
    }

    // MARK: - 全コマンド辞書
    static let all: [String: CommandGuideEntry] = [

        // ── Arc 1 ──────────────────────────────────────
        "git init": .init(
            icon: "sparkles",
            what: "リポジトリを新規作成する",
            example: "git init",
            tip: "プロジェクトで最初に1回だけ実行。\n.git フォルダが生まれてコミが住み始める！",
            color: Color(red: 0.56, green: 0.85, blue: 1.00)
        ),
        "git status": .init(
            icon: "list.clipboard",
            what: "現在の状態を確認する",
            example: "git status",
            tip: "迷ったらまず status から。\nWorking / Staged の状況が一目でわかる！",
            color: Color(red: 0.56, green: 0.85, blue: 1.00)
        ),
        "git add": .init(
            icon: "shippingbox",
            what: "変更をステージ（宅配ボックス）に追加",
            example: "git add .\ngit add ファイル名",
            tip: "コミットしたい変更を「選ぶ」作業。\n. で全ファイルをまとめて追加できる。",
            color: Color(red: 1.00, green: 0.85, blue: 0.50)
        ),
        "git commit": .init(
            icon: "building.columns",
            what: "変更をスナップショットとして保存",
            example: "git commit -m \"メッセージ\"",
            tip: "ゲームのセーブポイント！\nいつでも過去に戻れるようになる。",
            color: Color(red: 0.60, green: 1.00, blue: 0.75)
        ),
        "git log": .init(
            icon: "scroll",
            what: "コミット履歴を一覧表示する",
            example: "git log\ngit log --oneline",
            tip: "--oneline でスッキリ表示。\n過去のセーブ履歴を全部確認できる。",
            color: Color(red: 0.60, green: 1.00, blue: 0.75)
        ),
        "git push": .init(
            icon: "paperplane.fill",
            what: "ローカルの変更をリモートへ送る",
            example: "git push\ngit push origin main",
            tip: "チームへの「共有」「デプロイ」の最終ステップ。\nCI/CD のトリガーになることも多い。",
            color: Color(red: 0.85, green: 0.65, blue: 1.00)
        ),
        "git pull": .init(
            icon: "arrow.down.circle.fill",
            what: "リモートの変更を取り込む",
            example: "git pull",
            tip: "作業前に必ず pull して最新に！\nfetch + merge を同時にやるショートカット。",
            color: Color(red: 0.85, green: 0.65, blue: 1.00)
        ),
        "git remote add": .init(
            icon: "network",
            what: "リモートリポジトリを登録する",
            example: "git remote add origin <URL>",
            tip: "origin は慣習的な名前。\nGitHub などのリモートと繋げる橋。",
            color: Color(red: 0.85, green: 0.65, blue: 1.00)
        ),

        // ── Arc 2 ──────────────────────────────────────
        "git branch": .init(
            icon: "arrow.triangle.branch",
            what: "ブランチを作成・一覧表示する",
            example: "git branch feature/ui\ngit branch（一覧）",
            tip: "main を汚さずに作業できる「枝」。\n機能ごとにブランチを切るのが定石！",
            color: Color(red: 0.52, green: 0.92, blue: 0.65)
        ),
        "git checkout": .init(
            icon: "arrow.left.arrow.right.circle",
            what: "ブランチを切り替える（作成も可）",
            example: "git checkout main\ngit checkout -b 新ブランチ",
            tip: "-b で作成と移動を同時に。\ngit switch でも同じことができる。",
            color: Color(red: 0.52, green: 0.92, blue: 0.65)
        ),
        "git merge": .init(
            icon: "arrow.triangle.merge",
            what: "ブランチの変更を統合する",
            example: "git merge feature/ui",
            tip: "作業ブランチを main に取り込む。\nPull Request は merge の Web UI 版！",
            color: Color(red: 0.52, green: 0.92, blue: 0.65)
        ),

        // ── Arc 3 ──────────────────────────────────────
        "git diff": .init(
            icon: "plusminus.circle",
            what: "変更の差分を確認する",
            example: "git diff\ngit diff HEAD",
            tip: "コミット前に「何を変えたか」を確認。\n赤が削除・緑が追加の基本ルール。",
            color: Color(red: 1.00, green: 0.82, blue: 0.42)
        ),
        "git stash": .init(
            icon: "tray.and.arrow.down.fill",
            what: "作業中の変更を一時退避する",
            example: "git stash\ngit stash pop",
            tip: "「ちょっと待って！」な時の救済コマンド。\npop で退避した作業を戻せる。",
            color: Color(red: 1.00, green: 0.82, blue: 0.42)
        ),

        // ── Arc 4 ──────────────────────────────────────
        "git revert": .init(
            icon: "arrow.uturn.backward.circle.fill",
            what: "コミットを「打ち消し」コミットで戻す",
            example: "git revert HEAD",
            tip: "歴史を消さずに安全に巻き戻せる。\nチーム開発での取り消しにおすすめ！",
            color: Color(red: 1.00, green: 0.60, blue: 0.50)
        ),
        "git reset": .init(
            icon: "arrow.counterclockwise.circle.fill",
            what: "コミットを取り消す（3モードあり）",
            example: "git reset --soft HEAD~1\ngit reset --hard HEAD~1",
            tip: "soft: コミットだけ消す\nmixed: add も戻す\nhard: 全部消す（⚠️ 慎重に！）",
            color: Color(red: 1.00, green: 0.60, blue: 0.50)
        ),
        "git reflog": .init(
            icon: "clock.arrow.circlepath",
            what: "Git の全操作履歴を確認する",
            example: "git reflog",
            tip: "reset --hard で消えたコミットも復元可！\nGitの最強のセーフティネット。",
            color: Color(red: 1.00, green: 0.60, blue: 0.50)
        ),

        // ── Arc 5 ──────────────────────────────────────
        "git rebase": .init(
            icon: "arrow.triangle.2.circlepath",
            what: "ブランチの起点を付け替える",
            example: "git rebase main\ngit rebase -i HEAD~3",
            tip: "merge より履歴がキレイになる。\n-i で対話モード → コミットを整理できる！",
            color: Color(red: 0.56, green: 0.85, blue: 1.00)
        ),
        "git cherry-pick": .init(
            icon: "arrow.right.circle.fill",
            what: "特定のコミットだけを取り込む",
            example: "git cherry-pick abc1234",
            tip: "「あのコミットだけ欲しい！」ときに。\nハッシュの先頭7文字でOK。",
            color: Color(red: 0.56, green: 0.85, blue: 1.00)
        ),
        "git tag": .init(
            icon: "tag.fill",
            what: "コミットにバージョンタグを付ける",
            example: "git tag v1.0.0\ngit push origin v1.0.0",
            tip: "リリースのマーカーとして使う。\nセマンティックバージョニング（v1.0.0）と相性◎",
            color: Color(red: 1.00, green: 0.82, blue: 0.42)
        ),

        // ── Arc 6 ──────────────────────────────────────
        "git blame": .init(
            icon: "person.text.rectangle.fill",
            what: "各行の最終変更者・日時を調べる",
            example: "git blame ファイル名",
            tip: "「誰がいつこのコードを書いたか」がわかる。\n犯人探しより原因調査に使おう！",
            color: Color(red: 0.52, green: 0.92, blue: 0.65)
        ),
        "git bisect": .init(
            icon: "magnifyingglass.circle.fill",
            what: "バグを二分探索で特定する",
            example: "git bisect start\ngit bisect bad / good <hash>",
            tip: "大量のコミットから1つのバグを効率よく探す。\nGit 最強のデバッグ技！",
            color: Color(red: 0.52, green: 0.92, blue: 0.65)
        ),
        "touch .gitignore": .init(
            icon: "eye.slash.fill",
            what: "Gitに無視させるファイルを定義する",
            example: "echo 'node_modules/' >> .gitignore\necho '.env' >> .gitignore",
            tip: ".env, node_modules, .DS_Store などを書こう。\nリポジトリをスッキリ、秘密を守れる！",
            color: Color(red: 1.00, green: 0.82, blue: 0.42)
        ),
    ]
}
