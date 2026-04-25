//
//  ContentView.swift
//  gitStar
//
//  Created by 茂木史明 on 2026/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = GameViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.gitStarBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 上：街 UI
                    CityStageView(git: vm.git)
                        .frame(height: geo.size.height * 0.55)

                    // 下：モードで切り替わるパネル
                    Group {
                        switch vm.mode {
                        case .story:
                            DialogueView(engine: vm.dialogueEngine)
                        case .mission:
                            if let mission = vm.currentMission {
                                MissionView(
                                    mission: mission,
                                    git: vm.git,
                                    inputText: $vm.commandInput,
                                    onSubmit: { vm.submitCommand($0) }
                                )
                            }
                        case .result:
                            if let result = vm.lastResult {
                                ResultView(result: result, onContinue: { vm.continueAfterResult() })
                            }
                        }
                    }
                    .frame(height: geo.size.height * 0.45)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: vm.mode)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear { vm.start() }
    }
}

// MARK: - ViewModel（ゲーム進行管理）
@MainActor
@Observable
class GameViewModel {
    var git = GitState()
    var dialogueEngine = DialogueEngine()
    var mode: GameMode = .story
    var currentMission: Mission? = nil
    var lastResult: CommandResult? = nil
    var commandInput: String = ""

    private var episodes: [Episode] = Arc1.episodes
    private var episodeIndex: Int = 0

    func start() {
        let saved = SaveManager.load()
        episodeIndex = saved.episodeIndex
        loadEpisode()
    }

    func loadEpisode() {
        guard episodeIndex < episodes.count else { return }
        let ep = episodes[episodeIndex]

        // ダイアログ終了後にミッションへ
        dialogueEngine.onFinished = { [weak self] in
            guard let self else { return }
            if let mission = self.episodes[self.episodeIndex].mission {
                withAnimation { self.mode = .mission }
                self.currentMission = mission
                self.commandInput = ""
            } else {
                self.nextEpisode()
            }
        }

        mode = .story
        dialogueEngine.load(ep.lines)
        SaveManager.save(episodeIndex: episodeIndex)
    }

    func submitCommand(_ cmd: String) {
        guard let mission = currentMission else { return }
        let gitResult = git.apply(command: cmd)

        if mission.validate(cmd) {
            // ミッション検証が通れば必ず success 扱い
            lastResult = .success(gitResult.message)
            dialogueEngine.onFinished = { [weak self] in
                self?.nextEpisode()
            }
            withAnimation { mode = .result }
        } else {
            // 失敗：失敗フィードバック
            lastResult = .failure(mission.failLine.text)
            withAnimation { mode = .result }
        }
        commandInput = ""
    }

    func continueAfterResult() {
        guard let result = lastResult else { return }
        if result.isSuccess {
            // 成功セリフを表示してから次へ
            if let mission = currentMission {
                dialogueEngine.onFinished = { [weak self] in self?.nextEpisode() }
                mode = .story
                dialogueEngine.load([mission.successLine])
            }
        } else {
            // 失敗：ミッションに戻る
            mode = .mission
            commandInput = ""
        }
    }

    private func nextEpisode() {
        episodeIndex += 1
        if episodeIndex < episodes.count {
            loadEpisode()
        }
    }
}

#Preview {
    ContentView()
}
