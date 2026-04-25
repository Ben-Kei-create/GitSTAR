//
//  StoryDataArc3to6.swift
//  gitStar
//

import Foundation

// ════════════════════════════════════════
// MARK: - Arc 3「チーム実戦編」
// ════════════════════════════════════════
enum Arc3 {
    static let arc = Arc(
        number: 3,
        title: "チーム実戦編",
        subtitle: "衝突と解決の技術",
        commands: ["git diff", "git stash", "git stash pop", "conflict 解消"],
        episodes: [ep1_intro, ep2_diff, ep3_stash, ep4_conflictIntro, ep5_conflictResolve, ep6_review]
    )

    static let ep1_intro = Episode(
        id: "arc3_ep1",
        lines: [
            .init(speaker: .master, text: "Arc 3 へようこそ。\nいよいよ実戦の章だ。"),
            .init(speaker: .bran,   text: "ねえ、聞いてよ！\nさっきぼくが map.txt を編集してたら\nキミも同じファイルを変えてたんだって！"),
            .init(speaker: .komi,   text: "これが「コンフリクト」だよ！\n\n同じファイルの同じ箇所を\n別々の人が変えると起きるんだ。\n\nチーム開発では必ず起きる。\nでも怖くないよ！"),
            .init(speaker: .master, text: "まずは「差分を確認する力」から\n身につけよう。\n`git diff` がその道具だ。"),
        ],
        mission: nil
    )

    static let ep2_diff = Episode(
        id: "arc3_ep2",
        lines: [
            .init(speaker: .komi, text: "`git diff` は\n「何が変わったか」を見せてくれるよ。\n\n緑の行が追加、赤の行が削除。\nマージ前に必ず確認する習慣をつけよう！"),
            .init(speaker: .bran, text: "ぼくはよく `git diff HEAD` で\n最後のコミットからの変化を確認してるよ。\nおすすめ！"),
        ],
        mission: Mission(
            prompt: "今の作業内容と前回の差分を確認しよう",
            hint: "git diff",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git diff") },
            successLine: .init(speaker: .komi, text: "バッチリ！\n+（追加）と −（削除）で\n変更内容が一目でわかるね。"),
            failLine: .init(speaker: .komi, text: "`git diff` だよ！\n差分（difference）を表示するコマンド！")
        ),
        onLoad: { git in
            if git.workingFiles.isEmpty {
                git.workingFiles = [.init(name: "map.txt", status: .modified)]
            }
        }
    )

    static let ep3_stash = Episode(
        id: "arc3_ep3",
        lines: [
            .init(speaker: .bran, text: "ねえ、急に別の作業を頼まれた！\nでも今やってる作業が途中で\nコミットもできないよ…"),
            .init(speaker: .komi, text: "そんなときが `git stash` の出番！\n\n作業を「引き出し」に一時退避して\nブランチをクリーンな状態にできるんだ。"),
            .init(speaker: .komi, text: "別の作業が終わったら\n`git stash pop` で退避した作業を\nまた取り出せるよ！\n\n作業をなかったことにするんじゃなく、\n一時保存するイメージだよ。"),
        ],
        mission: Mission(
            prompt: "途中の作業を一時退避しよう",
            hint: "git stash",
            validate: { $0.trimmingCharacters(in: .whitespaces) == "git stash" },
            successLine: .init(speaker: .komi, text: "📎 退避完了！\n作業部屋がクリーンになったね。\n`git stash pop` でいつでも戻せるよ！"),
            failLine: .init(speaker: .komi, text: "`git stash` だよ！\n引き出しに隠すイメージ！")
        ),
        onLoad: { git in
            git.workingFiles = [.init(name: "new-feature.txt", status: .modified)]
        }
    )

    static let ep4_conflictIntro = Episode(
        id: "arc3_ep4",
        lines: [
            .init(speaker: .bran,   text: "あー！コンフリクトが起きた！\n\n```\n<<<<<<< HEAD\nぼくの変更\n=======\nキミの変更\n>>>>>>> feature/new-area\n```\n\nこれ怖い…"),
            .init(speaker: .komi,   text: "落ち着いて！\nGit が「ここが衝突してるよ」って\n教えてくれてるだけだよ。\n\n`<<<<<<<` から `>>>>>>>` の間を\n自分で編集すれば OK！"),
            .init(speaker: .master, text: "コンフリクトは「ミス」じゃない。\nチームで作業していれば\n自然に起きることだ。\n\n大事なのは落ち着いて解消すること。"),
            .init(speaker: .komi,   text: "手順は3つだけ！\n\n① ファイルを開いてマーカーを見る\n② どの変更を採用するか決める\n③ マーカーを全部消して保存\n\nそれだけだよ！"),
        ],
        mission: nil
    )

    static let ep5_conflictResolve = Episode(
        id: "arc3_ep5",
        lines: [
            .init(speaker: .bran, text: "コンフリクトを解消して\ngit add したら、\nもう一度 git commit で完了だよ！"),
            .init(speaker: .komi, text: "解消後のコミットを\n「マージコミット」って言うよ。\n\n2つの歴史が1本になった証だ！"),
        ],
        mission: Mission(
            prompt: "コンフリクトを解消してコミットしよう\n（git add → git commit の流れで）",
            hint: "git add map.txt → git commit -m \"コンフリクトを解消\"",
            validate: { cmd in
                let c = cmd.trimmingCharacters(in: .whitespaces)
                return (c.hasPrefix("git commit -m") && c.contains("\"")) || c.hasPrefix("git add")
            },
            successLine: .init(speaker: .komi, text: "🎉 コンフリクト解消完了！\n\n2つの変更が1つになったよ。\nこれがチーム開発の醍醐味だ！"),
            failLine: .init(speaker: .komi, text: "まず `git add map.txt` で\nステージして、\nそれから `git commit -m \"...\"` だよ！")
        ),
        onLoad: { git in
            git.workingFiles = [.init(name: "map.txt", status: .modified)]
        }
    )

    static let ep6_review = Episode(
        id: "arc3_ep6",
        lines: [
            .init(speaker: .master, text: "よくやった。\nコンフリクトを恐れなくなったな。"),
            .init(speaker: .bran,   text: "ぼくもコンフリクトは怖かったけど、\n仕組みがわかったら\n全然大丈夫だった！"),
            .init(speaker: .komi,   text: "git diff で確認する習慣、\ngit stash で安全な作業切り替え、\nそしてコンフリクト解消。\n\nこれで実際のチーム開発に入れるよ！"),
        ],
        mission: nil
    )
}

// ════════════════════════════════════════
// MARK: - Arc 4「緊急対応編」
// ════════════════════════════════════════
enum Arc4 {
    static let arc = Arc(
        number: 4,
        title: "緊急対応編",
        subtitle: "やらかした夜に救ってくれる魔法",
        commands: ["git revert", "git reset", "git reflog"],
        episodes: [ep1_alarm, ep2_findBug, ep3_revert, ep4_reset, ep5_reflog, ep6_rescue]
    )

    static let ep1_alarm = Episode(
        id: "arc4_ep1",
        lines: [
            .init(speaker: .komi,   text: "…深夜2時。\n突然メッセージが来た。"),
            .init(speaker: .bran,   text: "「本番が壊れた！！\nさっきのデプロイ以降から\nエラーが出てる！！」"),
            .init(speaker: .master, text: "焦るな。\nGit があれば必ず戻れる。\n\nまずログで「どのコミットから\n壊れたか」を特定しよう。"),
            .init(speaker: .komi,   text: "こういうとき `git log --oneline` が\n超便利なんだ。\n\n短く一覧で見られるから\n原因のコミットを素早く見つけられるよ！"),
        ],
        mission: nil
    )

    static let ep2_findBug = Episode(
        id: "arc4_ep2",
        lines: [
            .init(speaker: .komi, text: "まずログを確認しよう。\n`--oneline` をつけると\nスッキリ一覧で見れるよ！"),
        ],
        mission: Mission(
            prompt: "コミット履歴を一行ずつ確認しよう",
            hint: "git log --oneline",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git log") },
            successLine: .init(speaker: .komi, text: "見えた！\n一番上のコミットが怪しそう…\n次はこれを安全に取り消そう！"),
            failLine: .init(speaker: .komi, text: "`git log --oneline` だよ！\n--oneline で見やすくなるよ！")
        ),
        onLoad: { git in
            if git.commits.isEmpty {
                git.commits = [
                    .init(hash: "a1b2c3d", message: "地図を更新", branch: "main"),
                    .init(hash: "e4f5g6h", message: "バグのある変更 ← これが原因！", branch: "main"),
                ]
            }
        }
    )

    static let ep3_revert = Episode(
        id: "arc4_ep3",
        lines: [
            .init(speaker: .master, text: "取り消しには2つの方法がある。\nまず安全な方法から教えよう。\n`git revert` だ。"),
            .init(speaker: .komi,   text: "`git revert` は\n「打ち消しコミット」を追加するよ。\n\n歴史を消さずに「なかったことにする」\nコミットを積むんだ。\n\n本番で使う安全な取り消し方法だよ！"),
            .init(speaker: .bran,   text: "チームで開発してると\n歴史を書き換えると\n他の人が混乱するから、\nrevert が鉄則なんだよね！"),
        ],
        mission: Mission(
            prompt: "最新のコミットを安全に取り消そう",
            hint: "git revert HEAD",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git revert") },
            successLine: .init(speaker: .komi, text: "↩️ 完璧！\n「打ち消し」コミットが追加されたよ。\n\n歴史は消えず、安全に戻せた！\nこれが本番での正解だよ。"),
            failLine: .init(speaker: .komi, text: "`git revert HEAD` だよ！\nHEAD = 最新のコミットのこと！")
        )
    )

    static let ep4_reset = Episode(
        id: "arc4_ep4",
        lines: [
            .init(speaker: .komi,   text: "もう一つの方法が `git reset` だよ。\nこちらは歴史を直接書き換える。\n\nローカルでの作業ミスを\n取り消すときに使うよ！"),
            .init(speaker: .master, text: "reset には3種類ある。\n\n--soft  : コミットだけ取り消す\n--mixed : staging も取り消す（デフォルト）\n--hard  : 全部取り消す（危険！）\n\n用途で使い分けるんだ。"),
            .init(speaker: .komi,   text: "⚠️ `git reset --hard` は\nコードも全部消えるから\nローカル限定で使おう！\n\npush 後のコミットに使うと\nチームメンバーが混乱するよ！"),
        ],
        mission: Mission(
            prompt: "ローカルの最新コミットを取り消して\n作業を staging に残そう",
            hint: "git reset --soft HEAD~1",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git reset") },
            successLine: .init(speaker: .komi, text: "完璧！\nコミットが取り消されて\n変更が staging に残ったよ。\n\nsoft / mixed / hard の使い分け、\n覚えておいてね！"),
            failLine: .init(speaker: .komi, text: "`git reset --soft HEAD~1` だよ！\nHEAD~1 = 1つ前のコミットに戻す！")
        )
    )

    static let ep5_reflog = Episode(
        id: "arc4_ep5",
        lines: [
            .init(speaker: .bran,   text: "あ…reset --hard したら\n大事なコミットまで消えた…😱"),
            .init(speaker: .komi,   text: "大丈夫！\n`git reflog` という\n最後の砦があるよ！\n\nGit はすべての操作履歴を\n密かに保存してるんだ。"),
            .init(speaker: .master, text: "reflog は Git の「黒い手帳」だ。\nreset で消したと思っても、\n30日間は必ず復元できる。"),
            .init(speaker: .komi,   text: "reflog で消えたコミットの\nhash を見つけて、\n`git checkout <hash>` で\n復元できるよ！\n\nこれを知ってるだけで\nGit が怖くなくなるんだ！"),
        ],
        mission: Mission(
            prompt: "操作履歴（reflog）を確認して、\n消えたコミットを探そう",
            hint: "git reflog",
            validate: { $0.trimmingCharacters(in: .whitespaces) == "git reflog" },
            successLine: .init(speaker: .komi, text: "🔍 見えた！\nHEAD@{1} に消えたコミットがあるよ！\n\n`git checkout HEAD@{1}` か\n`git reset --hard HEAD@{1}` で復元できる！"),
            failLine: .init(speaker: .komi, text: "`git reflog` だよ！\nref（参照）の log（記録）！")
        )
    )

    static let ep6_rescue = Episode(
        id: "arc4_ep6",
        lines: [
            .init(speaker: .bran,   text: "助かった〜！\nreflog で復元できた！！"),
            .init(speaker: .master, text: "よくやった。\nパニックにならず\n手順通りに対処できた。"),
            .init(speaker: .komi,   text: "緊急対応の鉄則をまとめると：\n\n✅ まず git log で原因を特定\n✅ 本番は git revert（歴史を消さない）\n✅ ローカルは git reset（直接書き換え）\n✅ 消えても git reflog で復元できる\n\nこれで深夜の事故も怖くない！"),
        ],
        mission: nil
    )
}

// ════════════════════════════════════════
// MARK: - Arc 5「熟練者編」
// ════════════════════════════════════════
enum Arc5 {
    static let arc = Arc(
        number: 5,
        title: "熟練者編",
        subtitle: "歴史を美しく整える力",
        commands: ["git rebase", "git rebase -i", "git cherry-pick", "git tag"],
        episodes: [ep1_rebayIntro, ep2_rebase, ep3_rebaseInteractive, ep4_cherryPick, ep5_tag, ep6_mastery]
    )

    static let ep1_rebayIntro = Episode(
        id: "arc5_ep1",
        lines: [
            .init(speaker: .master, text: "Arc 5 だ。\nここからは本物の熟練者の技を教えよう。"),
            .init(speaker: .rebay,  text: "よ。リベイだ。\nおれが「歴史を編み直す力」を\n教えてやる。\n\n…使いすぎると危険だけどな。"),
            .init(speaker: .komi,   text: "リベイさんは\n`git rebase` の達人だよ！\n\nrebase ってね、\nブランチの「根っこ」を付け替える魔法なんだ。"),
            .init(speaker: .rebay,  text: "merge だとブランチの\n「合流点」が歴史に残る。\n\nrebase だと歴史が\n一直線になる。\n\nどちらが正解かは\nチームの方針次第だ。"),
        ],
        mission: nil
    )

    static let ep2_rebase = Episode(
        id: "arc5_ep2",
        lines: [
            .init(speaker: .rebay, text: "まず基本の rebase だ。\nfeature ブランチを\nmain の最新に追いつかせる。"),
            .init(speaker: .komi,  text: "merge との違いを見てみよう！\n\nmerge:  A－B－C－M（マージコミット）\nrebase: A－B－C（一直線）\n\nrebase の方が歴史がきれいだよ！"),
        ],
        mission: Mission(
            prompt: "feature ブランチを main の先端に rebase しよう",
            hint: "git rebase main",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git rebase") && !$0.contains("-i") },
            successLine: .init(speaker: .rebay, text: "悪くない。\n歴史が一直線になった。\n\nこれが rebase の基本だ。"),
            failLine: .init(speaker: .rebay, text: "`git rebase main` だ。\n簡単だろ？")
        ),
        onLoad: { git in
            if !git.branches.contains("feature/clean") {
                git.branches.append("feature/clean")
            }
        }
    )

    static let ep3_rebaseInteractive = Episode(
        id: "arc5_ep3",
        lines: [
            .init(speaker: .rebay, text: "次は `git rebase -i` だ。\nこいつが本物の力だ。"),
            .init(speaker: .komi,  text: "`-i` は interactive（対話的）の意味！\n\nコミットの順番を変えたり\n複数のコミットを1つにまとめたり\nメッセージを書き直したりできるよ！"),
            .init(speaker: .rebay, text: "「あ、このコミット3個は\n1つにまとめるべきだった…」\n\nそんなときに使うんだ。\nPR を出す前に\n歴史を整えるのがプロの仕事だ。"),
            .init(speaker: .komi,  text: "操作は：\npick = そのまま使う\nsquash = 前のコミットに統合\nreword = メッセージを変更\ndelete = 削除\n\nどれも強力だよ！"),
        ],
        mission: Mission(
            prompt: "直近3コミットを対話的に整理しよう",
            hint: "git rebase -i HEAD~3",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git rebase -i") || $0.trimmingCharacters(in: .whitespaces).hasPrefix("git rebase --interactive") },
            successLine: .init(speaker: .rebay, text: "…いい手つきだ。\n歴史が整った。\n\nこれが本物の rebase だ。"),
            failLine: .init(speaker: .rebay, text: "`git rebase -i HEAD~3` だ。\nHEAD~3 = 直近3コミット。")
        )
    )

    static let ep4_cherryPick = Episode(
        id: "arc5_ep4",
        lines: [
            .init(speaker: .rebay, text: "次は `git cherry-pick`。\n特定のコミットだけを\n「つまみ食い」する技だ。"),
            .init(speaker: .komi,  text: "たとえばこんな場面で使うよ！\n\n・別ブランチの特定の修正だけ取り込みたい\n・本番ブランチに緊急の bugfix だけ当てたい\n\nブランチ全体じゃなく\nコミット単位で取り込めるんだ！"),
            .init(speaker: .bran,  text: "ぼく先日使ったよ！\n古いブランチにあった\n便利な実装だけ\n取り込めて感動した〜"),
        ],
        mission: Mission(
            prompt: "別ブランチの特定コミットだけを\n現在のブランチに取り込もう",
            hint: "git cherry-pick a1b2c3d",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git cherry-pick") },
            successLine: .init(speaker: .komi, text: "🍒 cherry-pick 完了！\n必要なコミットだけ取り込めたよ！\n\nこれが「つまみ食い」の技だ！"),
            failLine: .init(speaker: .rebay, text: "`git cherry-pick <hash>` だ。\nhash はログで確認してくれ。")
        )
    )

    static let ep5_tag = Episode(
        id: "arc5_ep5",
        lines: [
            .init(speaker: .master, text: "リリースのタイミングで\n覚えておいてほしいのが\n`git tag` だ。"),
            .init(speaker: .komi,   text: "`git tag` は\nコミットに「名前」をつけること！\n\n`v1.0.0` とか `v2.3.1` みたいに\nリリースのバージョンを記録するよ。\n\nハッシュより人間に優しい！"),
            .init(speaker: .rebay,  text: "タグは変更されない。\nいつでもその時点の\nコードに戻れる。\n\nリリース管理の基本だ。"),
        ],
        mission: Mission(
            prompt: "今のコミットに v1.0.0 のタグをつけよう",
            hint: "git tag v1.0.0",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git tag ") },
            successLine: .init(speaker: .komi, text: "🏷️ タグ完成！\nv1.0.0 のリリース完了！\n\n`git push origin v1.0.0` で\nリモートにも送れるよ！"),
            failLine: .init(speaker: .komi, text: "`git tag v1.0.0` だよ！\nバージョン番号は自由につけていいよ！")
        )
    )

    static let ep6_mastery = Episode(
        id: "arc5_ep6",
        lines: [
            .init(speaker: .rebay,  text: "…よくここまで来た。\n\nrebase、cherry-pick、tag。\nこれだけ使えれば\n本物の開発者だ。"),
            .init(speaker: .komi,   text: "Arc 5 クリア！\n\nrebase は慎重に。\npush 済みのコミットへの rebase は\nチームを混乱させるから\nローカルだけに使おう！"),
            .init(speaker: .master, text: "最後の章が残っている。\nチームを率いる者の技術だ。"),
        ],
        mission: nil
    )
}

// ════════════════════════════════════════
// MARK: - Arc 6「チームリード編」
// ════════════════════════════════════════
enum Arc6 {
    static let arc = Arc(
        number: 6,
        title: "チームリード編",
        subtitle: "調査・管理・大崩壊からの守護",
        commands: ["git blame", "git bisect", "git log 高度", ".gitignore"],
        episodes: [ep1_lead, ep2_blame, ep3_bisect, ep4_logAdvanced, ep5_gitignore, ep6_finale]
    )

    static let ep1_lead = Episode(
        id: "arc6_ep1",
        lines: [
            .init(speaker: .master,  text: "最後の章だ。\nキミはいつしか\nチームの中心になった。"),
            .init(speaker: .logBaa,  text: "ほっほ。\nようやく会えたね。\nわたしはログ婆。\n\nGit の歴史を\n誰より深く読む者じゃよ。"),
            .init(speaker: .komi,    text: "ログ婆はね、`git blame` や\n`git bisect` の達人なんだよ！\n\nチームリードになると\nこういう「調査」の技術が\n特に重要になるんだ。"),
            .init(speaker: .logBaa,  text: "バグが起きたとき、\n「誰が、いつ、なぜ」この行を\n変えたのかがわかれば\n解決は早い。\n\nそれがログを読む力じゃ。"),
        ],
        mission: nil
    )

    static let ep2_blame = Episode(
        id: "arc6_ep2",
        lines: [
            .init(speaker: .logBaa, text: "`git blame <ファイル>` は\n各行が「誰のコミット」か\n教えてくれるんじゃ。"),
            .init(speaker: .komi,   text: "バグを見つけたとき、\nその行を blame すると\n「あ、このコミットで変わったんだ」\nってわかるよ！\n\n犯人探しじゃなくて\n文脈を理解するためのツールだよ。"),
            .init(speaker: .logBaa, text: "コードには必ず理由がある。\nblame でその理由を\n理解してほしい。"),
        ],
        mission: Mission(
            prompt: "map.txt の各行が\nいつ、どのコミットで変更されたか調べよう",
            hint: "git blame map.txt",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git blame") },
            successLine: .init(speaker: .logBaa, text: "ほっほ。\nよく読めたね。\n\nこれがコードの歴史を\n読む力じゃよ。"),
            failLine: .init(speaker: .logBaa, text: "`git blame map.txt` じゃよ。\nファイル名を忘れずにね。")
        )
    )

    static let ep3_bisect = Episode(
        id: "arc6_ep3",
        lines: [
            .init(speaker: .logBaa, text: "次は `git bisect` じゃ。\n\n「バグがいつ入ったか\nわからない」というとき、\n二分探索で特定できる魔法じゃ。"),
            .init(speaker: .komi,   text: "たとえば 100 個コミットがあって\nどれかがバグを入れたとして…\n\n手動で調べたら時間がかかるよね。\n\nbisect は「今はバグある？ない？」\nを繰り返して半分ずつ絞り込むんだ！"),
            .init(speaker: .logBaa, text: "やり方：\n\n① `git bisect start`\n② `git bisect bad`（今はバグあり）\n③ `git bisect good <hash>`（正常なコミット）\n④ Git が中間点を checkout してくれる\n⑤ ② ③ を繰り返して特定\n⑥ `git bisect reset` で終了"),
        ],
        mission: Mission(
            prompt: "bisect で調査を開始しよう",
            hint: "git bisect start",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git bisect") },
            successLine: .init(speaker: .logBaa, text: "ほっほ。\n二分探索の旅が始まったね。\n\n100 コミットも 7 回で特定できる。\nこれが知恵の力じゃ。"),
            failLine: .init(speaker: .logBaa, text: "`git bisect start` から始めるんじゃよ。")
        )
    )

    static let ep4_logAdvanced = Episode(
        id: "arc6_ep4",
        lines: [
            .init(speaker: .logBaa, text: "`git log` には\n強力なオプションがたくさんある。\n使いこなすと調査が格段に速くなる。"),
            .init(speaker: .komi,   text: "便利なオプションを紹介！\n\n`--author=\"名前\"` → 特定の人のコミットだけ\n`--since=\"2週間前\"` → 期間を絞る\n`--grep=\"キーワード\"` → メッセージで検索\n`-p` → 変更内容も一緒に表示\n`--stat` → ファイル変更の統計"),
            .init(speaker: .logBaa, text: "チームリードになったら\nログを読む時間が増える。\n\nこれらを使いこなせると\n問題の原因を素早く特定できる。"),
        ],
        mission: Mission(
            prompt: "過去2週間の自分のコミットを確認しよう",
            hint: "git log --oneline --since=\"2 weeks ago\"",
            validate: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("git log") },
            successLine: .init(speaker: .logBaa, text: "ほっほ！\nログを読む目が\n育ってきたね。\n\nこれで何でも調べられる！"),
            failLine: .init(speaker: .logBaa, text: "`git log --oneline` から\n試してみてね。")
        )
    )

    static let ep5_gitignore = Episode(
        id: "arc6_ep5",
        lines: [
            .init(speaker: .komi,   text: "最後に `.gitignore` の話！\n\nこれ、地味に超重要なんだよ。"),
            .init(speaker: .bran,   text: "`.gitignore` に書いたファイルは\nGit が完全無視してくれるんだ。\n\nパスワードとか API キーとか\n絶対コミットしちゃいけないものを\n指定しておくよ！"),
            .init(speaker: .komi,   text: "よく書くもの：\n\n.env（環境変数・秘密鍵）\nnode_modules/（依存ライブラリ）\n.DS_Store（Mac のシステムファイル）\nbuild/（ビルド成果物）\n*.log（ログファイル）"),
            .init(speaker: .master, text: ".gitignore は\nプロジェクト開始時に必ず作る。\nセキュリティの基本だ。"),
        ],
        mission: Mission(
            prompt: ".gitignore ファイルを作成しよう",
            hint: "touch .gitignore",
            validate: { let c = $0.trimmingCharacters(in: .whitespaces); return c == "touch .gitignore" || c.contains(".gitignore") },
            successLine: .init(speaker: .komi, text: "📄 .gitignore 完成！\n\nこれでチームの誰かが\n誤って秘密情報を\nコミットするのを防げるよ！"),
            failLine: .init(speaker: .komi, text: "`touch .gitignore` で作れるよ！")
        )
    )

    static let ep6_finale = Episode(
        id: "arc6_ep6",
        lines: [
            .init(speaker: .master, text: "…すべての章を終えた。"),
            .init(speaker: .komi,   text: "Arc 1 の `git init` から始まって、\nここまで来たね！\n\n正直、最初はぼくも\nキミがここまで来られるか\n心配してたんだ。\n\nでも、やり遂げた！"),
            .init(speaker: .bran,   text: "一緒に作業できて\n楽しかったよ！\n\nブランチは違っても\n最後は merge できるもんだね。"),
            .init(speaker: .rebay,  text: "……\n\nよくやった。"),
            .init(speaker: .logBaa, text: "ほっほ。\n記録者として\n立派になったものじゃ。\n\nGit の歴史が\nキミの歴史でもあるよ。"),
            .init(speaker: .master, text: "かつて「大崩壊」で\nすべての記録を失ったこの村は、\n今日また新しい記録者を得た。\n\nキミが積み重ねたコミットは\n永遠にここに残る。"),
            .init(speaker: .komi,   text: "GitSTAR\nクリア！！！\n\n🌟🌟🌟\n\nお疲れさま！！！"),
        ],
        mission: nil
    )
}
