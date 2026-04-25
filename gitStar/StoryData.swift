//
//  StoryData.swift
//  gitStar
//

import Foundation

// MARK: - エピソード定義
struct Episode {
    let id: String
    let lines: [DialogueLine]
    let mission: Mission?
}

// MARK: - Arc 1「ひとり開発編」
enum Arc1 {
    static let episodes: [Episode] = [
        ep1_intro,
        ep2_init,
        ep3_status,
        ep4_add,
        ep5_commit,
        ep6_log,
        ep7_push,
    ]

    // ── ep1: 世界観イントロ ──
    static let ep1_intro = Episode(
        id: "arc1_ep1",
        lines: [
            .init(speaker: .master,
                  text: "ようこそ、Git 村へ。\nここは「記録と歴史」の村だ。"),
            .init(speaker: .master,
                  text: "かつてこの村は「大崩壊」で\nすべての記録を失った。\n\nそれ以来、村人たちは\nすべてを残すことを誓ったんだ。"),
            .init(speaker: .komi,
                  text: "ぼくはコミ！\n.git の中に住む小さな精霊だよ。\nよろしくね！"),
            .init(speaker: .komi,
                  text: "Git ってね、一言でいうと\n「ファイルの歴史を記録する魔法」なんだ。\n\nいつ・誰が・何を変えたか、\nぜーんぶ覚えていてくれるよ！"),
            .init(speaker: .master,
                  text: "Git の世界には\n3 つの大切な場所がある。\n\n🏠 作業部屋（Working Directory）\n📦 宅配ボックス（Staging Area）\n🏛 役所（Repository）"),
            .init(speaker: .komi,
                  text: "この 3 つを旅するのが\nGit の基本の流れだよ。\n\nまずは実際にやってみよう！"),
        ],
        mission: nil
    )

    // ── ep2: git init ──
    static let ep2_init = Episode(
        id: "arc1_ep2",
        lines: [
            .init(speaker: .master,
                  text: "まず最初にやること。\nそれは「記録所を作る」ことだ。"),
            .init(speaker: .komi,
                  text: "`git init` を打つと\n.git っていう隠しフォルダが生まれて、\nそこがぼくのおうちになるんだよ！"),
        ],
        mission: Mission(
            prompt: "作業フォルダを Git で管理できるようにしよう",
            hint: "git init",
            validate: { $0.trimmingCharacters(in: .whitespaces) == "git init" },
            successLine: .init(speaker: .komi, text: "やった！.git が生まれた！\nこれでぼくが記録を始められるよ！"),
            failLine: .init(speaker: .komi, text: "うーん、ちょっと違うかな…\n`git init` って打ってみて！")
        )
    )

    // ── ep3: git status ──
    static let ep3_status = Episode(
        id: "arc1_ep3",
        lines: [
            .init(speaker: .komi,
                  text: "init したら、まず現状を確認！\n`git status` は「今どんな状態？」\nって聞くコマンドだよ。"),
            .init(speaker: .komi,
                  text: "作業部屋に map.txt があるね。\n変更されてるけど、まだ記録されてない状態だよ！"),
        ],
        mission: Mission(
            prompt: "今のフォルダの状態を確認してみよう",
            hint: "git status",
            validate: { $0.trimmingCharacters(in: .whitespaces) == "git status" },
            successLine: .init(speaker: .komi, text: "バッチリ！\nこうやっていつでも状態を\n確認できるんだよ。よく使うよ！"),
            failLine: .init(speaker: .komi, text: "`git status` だよ！\n状態（status）を見るコマンド！")
        )
    )

    // ── ep4: git add ──
    static let ep4_add = Episode(
        id: "arc1_ep4",
        lines: [
            .init(speaker: .master,
                  text: "map.txt を記録したい。\nだがいきなり登録はできない。"),
            .init(speaker: .komi,
                  text: "まず📦宅配ボックスに入れる必要があるんだ！\nそれが `git add` だよ。\n\nなんで 2 段階なの？って思うよね。"),
            .init(speaker: .komi,
                  text: "たとえば 10 個ファイルを変えても、\n「今日はこの 3 つだけ記録したい」\nってことが実務ではよくあるんだ。\n\nその選別ができるのが Staging の力だよ！"),
        ],
        mission: Mission(
            prompt: "map.txt を宅配ボックスに入れよう",
            hint: "git add map.txt",
            validate: { cmd in
                let c = cmd.trimmingCharacters(in: .whitespaces)
                return c == "git add map.txt" || c == "git add ."
            },
            successLine: .init(speaker: .komi, text: "完璧！\nmap.txt が📦に入ったよ！\n次は役所に登録だ！"),
            failLine: .init(speaker: .komi, text: "`git add map.txt` だよ！\nファイル名を忘れずに！")
        )
    )

    // ── ep5: git commit ──
    static let ep5_commit = Episode(
        id: "arc1_ep5",
        lines: [
            .init(speaker: .master,
                  text: "宅配ボックスに入ったものを\n正式に役所へ登録する。\nそれが `git commit` だ。"),
            .init(speaker: .komi,
                  text: "コミットには必ずメッセージをつけるよ！\n`-m \"メッセージ\"` って書くんだ。\n\n「何をしたか」が未来の自分に伝わる\n大事なメモになるよ！"),
        ],
        mission: Mission(
            prompt: "map.txt の追加を、メッセージ付きで記録しよう",
            hint: "git commit -m \"地図を追加\"",
            validate: { cmd in
                let c = cmd.trimmingCharacters(in: .whitespaces)
                return c.hasPrefix("git commit -m") && c.contains("\"")
            },
            successLine: .init(speaker: .komi, text: "🎉 初コミット達成！\n歴史の 1 ページ目が刻まれたよ！\nこれは永遠に残るんだ！"),
            failLine: .init(speaker: .komi, text: "`git commit -m \"メッセージ\"` の形で！\nメッセージはダブルクォートで囲んでね。")
        )
    )

    // ── ep6: git log ──
    static let ep6_log = Episode(
        id: "arc1_ep6",
        lines: [
            .init(speaker: .komi,
                  text: "コミットが積み重なると\n「歴史」ができあがるんだ！\n\n`git log` でその歴史を見られるよ。"),
            .init(speaker: .master,
                  text: "記録者にとって\nログを読む力は必須だ。\n過去を知ることで、未来が見える。"),
        ],
        mission: Mission(
            prompt: "これまでのコミット履歴を確認しよう",
            hint: "git log",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git log") },
            successLine: .init(speaker: .komi, text: "これが歴史の記録だよ！\nハッシュ（英数字）が\nそれぞれのコミットの ID になってるんだ。"),
            failLine: .init(speaker: .komi, text: "`git log` だよ！\nログ（log）= 記録の一覧！")
        )
    )

    // ── ep7: push（リモート接続） ──
    static let ep7_push = Episode(
        id: "arc1_ep7",
        lines: [
            .init(speaker: .master,
                  text: "最後だ。\n記録を隣村（リモート）にも届けよう。"),
            .init(speaker: .komi,
                  text: "GitHub みたいなところが「隣村」だよ！\nまず `git remote add` で繋いで、\n`git push` で送るんだ。"),
            .init(speaker: .komi,
                  text: "こうしておくと、\n・他の人と一緒に作業できる\n・パソコンが壊れても安心\nって最高だよね！"),
        ],
        mission: Mission(
            prompt: "リモートに push してみよう\n（git remote add は済んでいる想定）",
            hint: "git push",
            validate: { cmd in
                let c = cmd.trimmingCharacters(in: .whitespaces)
                return c == "git push" || c.hasPrefix("git push origin")
            },
            successLine: .init(speaker: .komi, text: "🚀 Push 完了！隣村に届いたよ！\n\nArc 1 クリア！おめでとう！\nGit の基本の流れ、完璧だよ！"),
            failLine: .init(speaker: .komi, text: "`git push` か\n`git push origin main` だよ！")
        )
    )
}
