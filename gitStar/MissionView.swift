//
//  MissionView.swift
//  gitStar
//

import SwiftUI

// MARK: - コマンドショートカット定義
struct CommandShortcut: Identifiable {
    let id = UUID()
    let label: String       // ボタン表示
    let fill: String        // 入力欄に入れる文字列
    let needsCursor: Bool   // true = "" の間にカーソルを置く
}

// ミッションの hint から文脈に合わせたショートカット一覧を生成
func shortcutsFor(hint: String) -> [CommandShortcut] {
    let all: [CommandShortcut] = [
        .init(label: "git init",       fill: "git init",                needsCursor: false),
        .init(label: "git status",     fill: "git status",              needsCursor: false),
        .init(label: "git add .",      fill: "git add .",               needsCursor: false),
        .init(label: "git add [file]", fill: "git add ",                needsCursor: false),
        .init(label: "git commit -m",  fill: "git commit -m \"\"",      needsCursor: true),
        .init(label: "git log",        fill: "git log",                 needsCursor: false),
        .init(label: "git log --oneline", fill: "git log --oneline",   needsCursor: false),
        .init(label: "git push",       fill: "git push",                needsCursor: false),
        .init(label: "git push origin main", fill: "git push origin main", needsCursor: false),
        .init(label: "git pull",       fill: "git pull",                needsCursor: false),
        .init(label: "git branch",     fill: "git branch ",             needsCursor: false),
        .init(label: "git checkout",   fill: "git checkout ",           needsCursor: false),
        .init(label: "git merge",      fill: "git merge ",              needsCursor: false),
        .init(label: "git remote add", fill: "git remote add origin ",  needsCursor: false),
        // Arc3
        .init(label: "git diff",       fill: "git diff",                needsCursor: false),
        .init(label: "git stash",      fill: "git stash",               needsCursor: false),
        .init(label: "git stash pop",  fill: "git stash pop",           needsCursor: false),
        // Arc4
        .init(label: "git revert",     fill: "git revert HEAD",         needsCursor: false),
        .init(label: "git reset --soft", fill: "git reset --soft HEAD~1", needsCursor: false),
        .init(label: "git reset --mixed", fill: "git reset --mixed HEAD~1", needsCursor: false),
        .init(label: "git reset --hard", fill: "git reset --hard HEAD~1", needsCursor: false),
        .init(label: "git reflog",     fill: "git reflog",              needsCursor: false),
        // Arc5
        .init(label: "git rebase",     fill: "git rebase ",             needsCursor: false),
        .init(label: "git rebase -i",  fill: "git rebase -i HEAD~3",   needsCursor: false),
        .init(label: "git cherry-pick", fill: "git cherry-pick ",       needsCursor: false),
        .init(label: "git tag",        fill: "git tag ",                needsCursor: false),
        // Arc6
        .init(label: "git blame",      fill: "git blame ",              needsCursor: false),
        .init(label: "git bisect",     fill: "git bisect ",             needsCursor: false),
        .init(label: "git log --graph", fill: "git log --oneline --graph --all", needsCursor: false),
        .init(label: "touch .gitignore", fill: "touch .gitignore",      needsCursor: false),
    ]

    // ヒントに近いコマンドを先頭に並べ替える
    let hintCmd = hint.components(separatedBy: " ").prefix(2).joined(separator: " ")
    var sorted = all.sorted { a, _ in a.fill.hasPrefix(hintCmd) }
    return sorted
}

// MARK: - MissionView
struct MissionView: View {
    let mission: Mission
    let git: GitState
    @Binding var inputText: String
    let history: [String]
    let onSubmit: (String) -> Void

    @FocusState private var focused: Bool
    @State private var showHint = false
    @State private var shakeTrigger = false
    @State private var historyIndex: Int = -1   // -1 = 入力中、0以上 = ヒストリー参照中

    private var shortcuts: [CommandShortcut] { shortcutsFor(hint: mission.hint) }
    private var hasHistory: Bool { !history.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── ヘッダー ──
            HStack(spacing: 10) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gitStarAccent)
                Text("MISSION")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.gitStarAccent)
                    .tracking(4)
                Spacer()
                Button {
                    withAnimation { showHint.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                            .font(.system(size: 12))
                        Text("ヒント")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.yellow.opacity(0.7))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 10)

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gitStarAccent.opacity(0.2))

            // ── ミッション内容 ──
            VStack(alignment: .leading, spacing: 10) {
                Text(mission.prompt)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if showHint {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.yellow)
                        Text(mission.hint)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.yellow.opacity(0.9))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()

            // ── コマンドショートカットバー ──
            VStack(alignment: .leading, spacing: 6) {
                Text("コマンド")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(.white.opacity(0.3))
                    .tracking(2)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(shortcuts) { shortcut in
                            Button {
                                applyShortcut(shortcut)
                            } label: {
                                Text(shortcut.label)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(
                                        inputText.hasPrefix(shortcut.fill.trimmingCharacters(in: .whitespaces).prefix(8))
                                        ? Color.gitStarAccent
                                        : .white.opacity(0.7)
                                    )
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.06))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gitStarAccent.opacity(0.25), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
            }
            .padding(.bottom, 8)

            // ── コマンド入力欄 ──
            HStack(spacing: 12) {
                Text("$")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.gitStarAccent)

                TextField("コマンドを入力…", text: $inputText)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(.white)
                    .tint(Color.gitStarAccent)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .focused($focused)
                    .onSubmit { submit() }

                if !inputText.isEmpty {
                    Button {
                        inputText = ""
                        historyIndex = -1
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                // ↑ ヒストリーボタン
                Button { cycleHistory() } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(hasHistory ? .white.opacity(0.55) : .white.opacity(0.15))
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(hasHistory ? Color.white.opacity(0.07) : .clear)
                        )
                }
                .disabled(!hasHistory)

                Button { submit() } label: {
                    Image(systemName: "return")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(inputText.isEmpty ? .white.opacity(0.2) : Color.gitStarAccent)
                }
                .disabled(inputText.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gitStarAccent.opacity(focused ? 0.6 : 0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .offset(x: shakeTrigger ? -8 : 0)
            .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: shakeTrigger)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.gitStarPanel)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gitStarAccent.opacity(0.3)),
            alignment: .top
        )
        .onAppear { focused = true }
    }

    // ↑ タップ → 最新から順に遡る。末尾まで行ったら最新に戻る
    private func cycleHistory() {
        guard !history.isEmpty else { return }
        if historyIndex == -1 {
            historyIndex = history.count - 1
        } else if historyIndex > 0 {
            historyIndex -= 1
        } else {
            historyIndex = history.count - 1
        }
        inputText = history[historyIndex]
        focused = true
    }

    // ショートカットボタンをタップ → 入力欄にセット
    private func applyShortcut(_ shortcut: CommandShortcut) {
        inputText = shortcut.fill
        focused = true
        // git commit -m "" の場合はすぐ送信せず、ユーザーにメッセージを打たせる
        // needsCursor = false のシンプルなコマンドはそのまま
    }

    private func submit() {
        let cmd = inputText.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { return }
        historyIndex = -1
        onSubmit(cmd)
        if !mission.validate(cmd) {
            shakeTrigger.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeTrigger = false
            }
        } else {
            inputText = ""
        }
    }
}

// MARK: - 結果フィードバック
struct ResultView: View {
    let result: CommandResult
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(result.isSuccess ? Color.green : Color.red.opacity(0.8))
                Text(result.isSuccess ? "SUCCESS" : "TRY AGAIN")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(result.isSuccess ? .green : .red.opacity(0.8))
                    .tracking(3)
            }

            Text(result.message)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(5)

            Spacer()

            HStack {
                Spacer()
                Button(action: onContinue) {
                    Text(result.isSuccess ? "次へ  ›" : "もう一度")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(result.isSuccess ? Color.gitStarAccent : .white.opacity(0.6))
                        .tracking(2)
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.gitStarPanel)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(
                    (result.isSuccess ? Color.green : Color.red).opacity(0.4)
                ),
            alignment: .top
        )
    }
}
