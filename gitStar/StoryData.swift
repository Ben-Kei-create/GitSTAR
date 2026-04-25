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
    var onLoad: ((GitState) -> Void)? = nil   // エピソード開始時の状態セットアップ
}

// MARK: - Arc 定義
struct Arc {
    let number: Int
    let title: String
    let subtitle: String
    let commands: [String]   // このArcで学ぶコマンド
    let episodes: [Episode]
}

// MARK: - 全Arc
enum GameContent {
    static let arcs: [Arc] = [Arc1.arc, Arc2.arc, Arc3.arc, Arc4.arc, Arc5.arc, Arc6.arc]
}

// ════════════════════════════════════════
// MARK: - Arc 1「ひとり開発編」
// ════════════════════════════════════════
enum Arc1 {
    static let arc = Arc(
        number: 1,
        title: "ひとり開発編",
        subtitle: "記録者の第一歩",
        commands: ["git init", "git status", "git add", "git commit", "git log", "git push"],
        episodes: [ep1_intro, ep2_init, ep3_status, ep4_add, ep5_commit, ep6_log, ep7_remoteAdd, ep8_push]
    )

    static let ep1_intro = Episode(
        id: "arc1_ep1",
        lines: [
            .init(speaker: .master, text: "ようこそ、Git 村へ。\nここは「記録と歴史」の村だ。"),
            .init(speaker: .master, text: "かつてこの村は「大崩壊」で\nすべての記録を失った。\n\nそれ以来、村人たちは\nすべてを残すことを誓ったんだ。"),
            .init(speaker: .komi,   text: "ぼくはコミ！\n.git の中に住む小さな精霊だよ。\nよろしくね！"),
            .init(speaker: .komi,   text: "Git ってね、一言でいうと\n「ファイルの歴史を記録する魔法」なんだ。\n\nいつ・誰が・何を変えたか、\nぜーんぶ覚えていてくれるよ！"),
            .init(speaker: .master, text: "Git の世界には\n3 つの大切な場所がある。\n\n🏠 作業部屋（Working Directory）\n📦 宅配ボックス（Staging Area）\n🏛 役所（Repository）"),
            .init(speaker: .komi,   text: "この 3 つを旅するのが\nGit の基本の流れだよ！\n\nさあ、始めよう！"),
        ],
        mission: nil
    )

    static let ep2_init = Episode(
        id: "arc1_ep2",
        lines: [
            .init(speaker: .master, text: "まず最初にやること。\nそれは「記録所を作る」ことだ。"),
            .init(speaker: .komi,   text: "`git init` を打つと\n.git っていう隠しフォルダが生まれて、\nそこがぼくのおうちになるんだよ！"),
        ],
        mission: Mission(
            prompt: "作業フォルダを Git で管理できるようにしよう",
            hint: "git init",
            validate: { $0.trimmingCharacters(in: .whitespaces) == "git init" },
            successLine: .init(speaker: .komi, text: "やった！.git が生まれた！\nこれでぼくが記録を始められるよ！"),
            failLine:    .init(speaker: .komi, text: "うーん、ちょっと違うかな…\n`git init` って打ってみて！")
        )
    )

    static let ep3_status = Episode(
        id: "arc1_ep3",
        lines: [
            .init(speaker: .komi, text: "init したら、まず現状を確認！\n`git status` は\n「今どんな状態？」って聞くコマンドだよ。"),
            .init(speaker: .komi, text: "作業部屋に map.txt があるよ。\n変更されてるけど、まだ記録されてない状態だ！"),
        ],
        mission: Mission(
            prompt: "今のフォルダの状態を確認してみよう",
            hint: "git status",
            validate: { $0.trimmingCharacters(in: .whitespaces) == "git status" },
            successLine: .init(speaker: .komi, text: "バッチリ！\nこうやっていつでも状態を\n確認できるんだよ。よく使うよ！"),
            failLine:    .init(speaker: .komi, text: "`git status` だよ！\n状態（status）を見るコマンド！")
        )
    )

    static let ep4_add = Episode(
        id: "arc1_ep4",
        lines: [
            .init(speaker: .master, text: "map.txt を記録したい。\nだがいきなり登録はできない。"),
            .init(speaker: .komi,   text: "まず📦宅配ボックスに入れる必要があるんだ！\nそれが `git add` だよ。"),
            .init(speaker: .komi,   text: "なんで 2 段階なの？って思うよね。\n\nたとえば 10 個ファイルを変えても\n「今日はこの 3 つだけ記録したい」\nってことが実務ではよくあるんだ。\n\nその選別ができるのが Staging の力だよ！"),
        ],
        mission: Mission(
            prompt: "map.txt を宅配ボックスに入れよう",
            hint: "git add map.txt",
            validate: { let c = $0.trimmingCharacters(in: .whitespaces); return c == "git add map.txt" || c == "git add ." },
            successLine: .init(speaker: .komi, text: "完璧！\nmap.txt が📦に入ったよ！\n次は役所に登録だ！"),
            failLine:    .init(speaker: .komi, text: "`git add map.txt` だよ！\nファイル名を忘れずに！")
        )
    )

    static let ep5_commit = Episode(
        id: "arc1_ep5",
        lines: [
            .init(speaker: .master, text: "宅配ボックスに入ったものを\n正式に役所へ登録する。\nそれが `git commit` だ。"),
            .init(speaker: .komi,   text: "コミットには必ずメッセージをつけるよ！\n`-m \"メッセージ\"` って書くんだ。\n\n「何をしたか」が未来の自分に伝わる\n大事なメモになるよ！"),
        ],
        mission: Mission(
            prompt: "map.txt の追加を、メッセージ付きで記録しよう",
            hint: "git commit -m \"地図を追加\"",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git commit -m") && $0.contains("\"") },
            successLine: .init(speaker: .komi, text: "🎉 初コミット達成！\n歴史の 1 ページ目が刻まれたよ！\nこれは永遠に残るんだ！"),
            failLine:    .init(speaker: .komi, text: "`git commit -m \"メッセージ\"` の形で！\nダブルクォートを忘れずに！")
        )
    )

    static let ep6_log = Episode(
        id: "arc1_ep6",
        lines: [
            .init(speaker: .komi,   text: "コミットが積み重なると\n「歴史」ができあがるんだ！\n\n`git log` でその歴史を見られるよ。"),
            .init(speaker: .master, text: "記録者にとって\nログを読む力は必須だ。\n過去を知ることで、未来が見える。"),
        ],
        mission: Mission(
            prompt: "これまでのコミット履歴を確認しよう",
            hint: "git log",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git log") },
            successLine: .init(speaker: .komi, text: "これが歴史の記録だよ！\nハッシュ（英数字）が\nそれぞれのコミットの ID になってるんだ。"),
            failLine:    .init(speaker: .komi, text: "`git log` だよ！\nログ（log）= 記録の一覧！")
        )
    )

    static let ep7_remoteAdd = Episode(
        id: "arc1_ep7",
        lines: [
            .init(speaker: .master, text: "最後の仕上げだ。\nこのままではローカルにしか記録がない。"),
            .init(speaker: .komi,   text: "GitHub みたいなところが「隣村」だよ！\nまず `git remote add` で繋ぐんだ。"),
            .init(speaker: .komi,   text: "こうしておくと\n・他の人と一緒に作業できる\n・パソコンが壊れても安心\nって最高だよね！"),
        ],
        mission: Mission(
            prompt: "リモート（隣村）を登録しよう",
            hint: "git remote add origin https://github.com/...",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git remote add") },
            successLine: .init(speaker: .komi, text: "🌐 繋がった！\nこれで push できるよ！"),
            failLine:    .init(speaker: .komi, text: "`git remote add origin <URL>` だよ！")
        )
    )

    static let ep8_push = Episode(
        id: "arc1_ep8",
        lines: [
            .init(speaker: .komi, text: "最後！\n`git push` で隣村に送ろう！"),
        ],
        mission: Mission(
            prompt: "コミットをリモートに push しよう",
            hint: "git push",
            validate: { let c = $0.trimmingCharacters(in: .whitespaces); return c == "git push" || c.hasPrefix("git push origin") },
            successLine: .init(speaker: .komi, text: "🚀 push 完了！\n隣村に届いたよ！\n\nArc 1 クリア！おめでとう！！"),
            failLine:    .init(speaker: .komi, text: "`git push` か\n`git push origin main` だよ！")
        )
    )
}

// ════════════════════════════════════════
// MARK: - Arc 2「チーム入門編」
// ════════════════════════════════════════
enum Arc2 {
    static let arc = Arc(
        number: 2,
        title: "チーム入門編",
        subtitle: "ブランチで世界が広がる",
        commands: ["git branch", "git checkout", "git switch", "git merge", "git pull"],
        episodes: [ep1_branIntro, ep2_branch, ep3_checkout, ep4_commitOnBranch, ep5_backToMain, ep6_merge, ep7_pull]
    )

    static let ep1_branIntro = Episode(
        id: "arc2_ep1",
        lines: [
            .init(speaker: .master, text: "Arc 1 おつかれさまだった。\nいよいよ次の章だ。"),
            .init(speaker: .bran,   text: "よっ！はじめまして！\nぼくはブラン。\nブランチの化身だよ！"),
            .init(speaker: .bran,   text: "ブランチって知ってる？\n木の「枝」のことだよ。\nGit でも同じイメージなんだ。"),
            .init(speaker: .komi,   text: "メインの歴史（main）から\n枝を生やして、そこで作業する。\n\n本番を壊さずに\n新機能を作れるのが最高なんだ！"),
            .init(speaker: .bran,   text: "たとえばさ、\n村の地図に「新エリア」を追加したいとき、\nいきなり本物の地図を書き換えたら怖いよね？\n\nだからコピーを作って、\nそこで試してから、完成したら本物に反映する！\nそれがブランチなんだよ。"),
        ],
        mission: nil
    )

    static let ep2_branch = Episode(
        id: "arc2_ep2",
        lines: [
            .init(speaker: .bran, text: "まずブランチを作ってみよう！\n`git branch <名前>` で新しい枝が生える。"),
            .init(speaker: .komi, text: "ブランチ名は\n何をする枝かわかる名前にするのがコツ！\n`feature/新機能名` って感じが多いよ。"),
        ],
        mission: Mission(
            prompt: "新エリアを追加するためのブランチを作ろう",
            hint: "git branch feature/new-area",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git branch feature/") || $0.trimmingCharacters(in: .whitespaces).hasPrefix("git branch ") && !$0.contains("--") },
            successLine: .init(speaker: .bran, text: "枝が生えた！\nでもまだ main にいるよ。\n次は移動しよう！"),
            failLine:    .init(speaker: .bran, text: "`git branch feature/new-area` だよ！\nスペースの後にブランチ名！")
        )
    )

    static let ep3_checkout = Episode(
        id: "arc2_ep3",
        lines: [
            .init(speaker: .bran, text: "ブランチを作っただけじゃ\nまだ main にいるんだ。\n\n`git checkout <名前>` で移動できるよ！"),
            .init(speaker: .komi, text: "最近は `git switch <名前>` でもOK！\nどちらでも同じ意味だよ。"),
        ],
        mission: Mission(
            prompt: "作ったブランチに移動しよう",
            hint: "git checkout feature/new-area",
            validate: { let c = $0.trimmingCharacters(in: .whitespaces); return c.hasPrefix("git checkout ") || c.hasPrefix("git switch ") },
            successLine: .init(speaker: .bran, text: "移動したよ！\nここが「新エリア開発室」だ。\n安心してどんどんコードを書ける！"),
            failLine:    .init(speaker: .bran, text: "`git checkout feature/new-area` だよ！\nブランチ名を合わせてね。")
        )
    )

    static let ep4_commitOnBranch = Episode(
        id: "arc2_ep4",
        lines: [
            .init(speaker: .bran, text: "このブランチで作業しよう！\n新エリアの地図ファイルが\n作業部屋に置いてあるよ。"),
            .init(speaker: .komi, text: "add → commit の流れは\nArc 1 で覚えたね。\nここでも全く同じだよ！"),
        ],
        mission: Mission(
            prompt: "new-area.txt を add して commit しよう\n（git add → git commit の流れで）",
            hint: "git add . → git commit -m \"新エリアを追加\"",
            validate: { let c = $0.trimmingCharacters(in: .whitespaces); return (c.hasPrefix("git commit -m") && c.contains("\"")) || c.hasPrefix("git add") },
            successLine: .init(speaker: .bran, text: "このブランチにコミットできた！\nmain には影響ゼロ。\n安全に作業できてるよ！"),
            failLine:    .init(speaker: .komi, text: "まず `git add .` してから\n`git commit -m \"メッセージ\"` だよ！")
        ),
        onLoad: { git in
            if git.workingFiles.isEmpty {
                git.workingFiles = [.init(name: "new-area.txt", status: .new)]
            }
        }
    )

    static let ep5_backToMain = Episode(
        id: "arc2_ep5",
        lines: [
            .init(speaker: .bran, text: "作業が終わったら\nmain ブランチに戻ろう。\n`git checkout main` だよ！"),
            .init(speaker: .komi, text: "戻ったら main のファイルが\nそのままになってるのを確認してみてね。\nブランチの変更は影響しないんだ！"),
        ],
        mission: Mission(
            prompt: "main ブランチに戻ろう",
            hint: "git checkout main",
            validate: { let c = $0.trimmingCharacters(in: .whitespaces); return c == "git checkout main" || c == "git switch main" },
            successLine: .init(speaker: .bran, text: "main に戻ったよ！\nnew-area.txt はまだここにはない。\n次はマージで取り込もう！"),
            failLine:    .init(speaker: .bran, text: "`git checkout main` だよ！")
        )
    )

    static let ep6_merge = Episode(
        id: "arc2_ep6",
        lines: [
            .init(speaker: .master, text: "ブランチで作った成果を\nメインの歴史に合流させる。\nそれが `git merge` だ。"),
            .init(speaker: .komi,   text: "マージすると\nブランチのコミットが main にも入るよ！\n\nこれで本番に新機能が追加されるんだ。"),
            .init(speaker: .bran,   text: "枝が幹に合流するイメージだね！\n上の街 UI で確認してみてね。"),
        ],
        mission: Mission(
            prompt: "feature ブランチを main にマージしよう",
            hint: "git merge feature/new-area",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git merge ") },
            successLine: .init(speaker: .komi, text: "🔀 マージ成功！\n新エリアが村の正式な地図に\n追加されたよ！"),
            failLine:    .init(speaker: .bran, text: "`git merge <ブランチ名>` だよ！\nマージしたいブランチ名を入れてね。")
        )
    )

    static let ep7_pull = Episode(
        id: "arc2_ep7",
        lines: [
            .init(speaker: .master, text: "チームで開発していると\n仲間が push した変更を\n自分のパソコンに取り込む必要がある。"),
            .init(speaker: .komi,   text: "それが `git pull` だよ！\npush の逆だね。\n\n「隣村から最新情報を受け取る」\nイメージだよ。"),
            .init(speaker: .bran,   text: "毎朝作業を始める前に\n`git pull` する習慣をつけると\nコンフリクトが減るよ！\n\nこれ、チーム開発の基本中の基本だから！"),
        ],
        mission: Mission(
            prompt: "リモートから最新の変更を取り込もう",
            hint: "git pull",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git pull") },
            successLine: .init(speaker: .komi, text: "⬇️ pull 完了！\n\nArc 2 クリア！\nブランチとチーム開発の基本、\nバッチリ身についたね！"),
            failLine:    .init(speaker: .komi, text: "`git pull` だよ！")
        ),
        onLoad: { git in git.remoteName = "origin" }
    )
}
