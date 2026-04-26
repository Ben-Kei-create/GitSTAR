//
//  MissionView.swift
//  gitStar
//

import SwiftUI

// MARK: - コマンドショートカット定義
struct CommandShortcut: Identifiable {
    let id = UUID()
    let label: String
    let fill: String
    let needsCursor: Bool
}

// ミッションの hint から文脈に合わせたショートカット一覧を生成
func shortcutsFor(hint: String) -> [CommandShortcut] {
    let all: [CommandShortcut] = [
        .init(label: "git init",          fill: "git init",                       needsCursor: false),
        .init(label: "git status",        fill: "git status",                     needsCursor: false),
        .init(label: "git add .",         fill: "git add .",                      needsCursor: false),
        .init(label: "git add [file]",    fill: "git add ",                       needsCursor: false),
        .init(label: "git commit -m",     fill: "git commit -m \"\"",             needsCursor: true),
        .init(label: "git log",           fill: "git log",                        needsCursor: false),
        .init(label: "git log --oneline", fill: "git log --oneline",              needsCursor: false),
        .init(label: "git push",          fill: "git push",                       needsCursor: false),
        .init(label: "git push origin",   fill: "git push origin main",           needsCursor: false),
        .init(label: "git pull",          fill: "git pull",                       needsCursor: false),
        .init(label: "git branch",        fill: "git branch ",                    needsCursor: false),
        .init(label: "git checkout",      fill: "git checkout ",                  needsCursor: false),
        .init(label: "git merge",         fill: "git merge ",                     needsCursor: false),
        .init(label: "git remote add",    fill: "git remote add origin ",         needsCursor: false),
        // Arc3
        .init(label: "git diff",          fill: "git diff",                       needsCursor: false),
        .init(label: "git stash",         fill: "git stash",                      needsCursor: false),
        .init(label: "git stash pop",     fill: "git stash pop",                  needsCursor: false),
        // Arc4
        .init(label: "git revert",        fill: "git revert HEAD",                needsCursor: false),
        .init(label: "git reset --soft",  fill: "git reset --soft HEAD~1",        needsCursor: false),
        .init(label: "git reset --mixed", fill: "git reset --mixed HEAD~1",       needsCursor: false),
        .init(label: "git reset --hard",  fill: "git reset --hard HEAD~1",        needsCursor: false),
        .init(label: "git reflog",        fill: "git reflog",                     needsCursor: false),
        // Arc5
        .init(label: "git rebase",        fill: "git rebase ",                    needsCursor: false),
        .init(label: "git rebase -i",     fill: "git rebase -i HEAD~3",           needsCursor: false),
        .init(label: "git cherry-pick",   fill: "git cherry-pick ",               needsCursor: false),
        .init(label: "git tag",           fill: "git tag ",                       needsCursor: false),
        // Arc6
        .init(label: "git blame",         fill: "git blame ",                     needsCursor: false),
        .init(label: "git bisect",        fill: "git bisect ",                    needsCursor: false),
        .init(label: "git log --graph",   fill: "git log --oneline --graph --all", needsCursor: false),
        .init(label: "touch .gitignore",  fill: "touch .gitignore",               needsCursor: false),
    ]
    let hintCmd = hint.components(separatedBy: " ").prefix(2).joined(separator: " ")
    let sorted = all.sorted { a, _ in a.fill.hasPrefix(hintCmd) }
    return sorted
}

// MARK: - MissionView（カスタムキーボード版）
struct MissionView: View {
    let mission: Mission
    let git: GitState
    @Binding var inputText: String
    let history: [String]
    let onSubmit: (String) -> Void

    @State private var showHint = false
    @State private var shakeTrigger = false
    @State private var historyIndex: Int = -1
    @State private var cursorVisible = true

    private var shortcuts: [CommandShortcut] { shortcutsFor(hint: mission.hint) }
    private var hasHistory: Bool { !history.isEmpty }

    var body: some View {
        VStack(spacing: 0) {

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
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gitStarAccent.opacity(0.2))

            // ── ミッション内容 ──
            VStack(alignment: .leading, spacing: 6) {
                Text(mission.prompt)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                if showHint {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text(mission.hint)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.yellow.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 6)

            // ── 入力ディスプレイ ──
            HStack(spacing: 0) {
                Text("$ ")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.gitStarAccent)

                Text(inputText.isEmpty ? "" : inputText)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(.white)

                // カーソル（点滅）
                Rectangle()
                    .frame(width: 2, height: 16)
                    .foregroundStyle(Color.gitStarAccent.opacity(cursorVisible ? 1 : 0))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            cursorVisible = false
                        }
                    }

                Spacer(minLength: 4)

                // ↑ ヒストリーボタン
                if hasHistory {
                    Button { cycleHistory() } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.trailing, 4)
                }

                // × クリアボタン
                if !inputText.isEmpty {
                    Button { inputText = ""; historyIndex = -1 } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gitStarAccent.opacity(0.45), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .offset(x: shakeTrigger ? -8 : 0)
            .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: shakeTrigger)

            // ── ショートカットバー ──
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(shortcuts) { shortcut in
                        Button { applyShortcut(shortcut) } label: {
                            Text(shortcut.label)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(
                                    inputText.hasPrefix(String(shortcut.fill.prefix(8)).trimmingCharacters(in: .whitespaces))
                                    ? Color.gitStarAccent
                                    : .white.opacity(0.65)
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.white.opacity(0.06))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 7)
                                                .stroke(Color.gitStarAccent.opacity(0.25), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
            }

            // ── カスタム Git キーボード ──
            GitKeyboardView(text: $inputText, onSubmit: submit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.gitStarPanel)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.gitStarAccent.opacity(0.3)),
            alignment: .top
        )
    }

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
    }

    private func applyShortcut(_ shortcut: CommandShortcut) {
        inputText = shortcut.fill
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

// MARK: - カスタム Git キーボード
struct GitKeyboardView: View {
    @Binding var text: String
    let onSubmit: () -> Void

    private let row1 = ["q","w","e","r","t","y","u","i","o","p"]
    private let row2 = ["a","s","d","f","g","h","j","k","l"]
    private let row3 = ["z","x","c","v","b","n","m"]
    // Git コマンドでよく使う特殊文字
    private let specials = ["-", ".", "\"", "~", "^", "/", "_", "1", "2", "3"]

    var body: some View {
        VStack(spacing: 4) {

            // ── 特殊文字行（横スクロール）──
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(specials, id: \.self) { key in
                        GitKey(label: key) { text.append(key) }
                    }
                    // スペースキーも特殊扱い
                    GitKey(label: "SP", wide: true) { text.append(" ") }
                }
                .padding(.horizontal, 10)
            }
            .padding(.bottom, 1)

            // ── QWERTY Row 1 ──
            HStack(spacing: 4) {
                ForEach(row1, id: \.self) { key in
                    GitKey(label: key, flexible: true) { text.append(key) }
                }
            }
            .padding(.horizontal, 8)

            // ── QWERTY Row 2 ──
            HStack(spacing: 4) {
                ForEach(row2, id: \.self) { key in
                    GitKey(label: key, flexible: true) { text.append(key) }
                }
            }
            .padding(.horizontal, 22)

            // ── QWERTY Row 3 + Backspace ──
            HStack(spacing: 4) {
                ForEach(row3, id: \.self) { key in
                    GitKey(label: key, flexible: true) { text.append(key) }
                }
                Spacer()
                // ⌫ 長押しで全消し
                Button(action: { if !text.isEmpty { text.removeLast() } }) {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.75))
                        .frame(width: 44, height: 32)
                        .background(Color.white.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5).onEnded { _ in text = "" }
                )
            }
            .padding(.horizontal, 8)

            // ── Space + 実行ボタン ──
            HStack(spacing: 8) {
                Button(action: { text.append(" ") }) {
                    Text("SPACE")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }

                Button(action: onSubmit) {
                    HStack(spacing: 5) {
                        Image(systemName: "return")
                            .font(.system(size: 12))
                        Text("実行")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    }
                    .foregroundStyle(text.isEmpty ? .white.opacity(0.25) : Color.gitStarAccent)
                    .frame(width: 88, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.gitStarAccent.opacity(text.isEmpty ? 0.04 : 0.18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.gitStarAccent.opacity(text.isEmpty ? 0.1 : 0.55), lineWidth: 1)
                            )
                    )
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color(white: 0.09))
    }
}

// MARK: - キーボードの1キー
struct GitKey: View {
    let label: String
    var wide: Bool = false
    var flexible: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.white.opacity(0.88))
                .frame(
                    minWidth: flexible ? 0 : (wide ? 44 : 30),
                    maxWidth: flexible ? .infinity : (wide ? 44 : 30)
                )
                .frame(height: 32)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
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
