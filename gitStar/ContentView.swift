//
//  ContentView.swift
//  gitStar
//

import SwiftUI

struct ContentView: View {
    var startFresh: Bool = false
    @State private var vm = GameViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.gitStarBackground.ignoresSafeArea()

                if vm.mode == .arcComplete {
                    if let arc = vm.completedArc {
                        ArcCompleteView(arc: arc) {
                            vm.startNextArc()
                        }
                        .transition(.opacity)
                    }
                } else {
                    VStack(spacing: 0) {
                        // 上：街UI
                        CityStageView(git: vm.git, arcNumber: vm.currentArcNumber)
                            .frame(height: geo.size.height * 0.55)

                        // 下：モード切り替えパネル
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
                                        history: vm.commandHistory,
                                        onSubmit: { vm.submitCommand($0) }
                                    )
                                }
                            case .result:
                                if let result = vm.lastResult {
                                    ResultView(result: result, onContinue: { vm.continueAfterResult() })
                                }
                            case .arcComplete:
                                EmptyView()
                            }
                        }
                        .frame(height: geo.size.height * 0.45)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: vm.mode)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if startFresh { SaveManager.reset() }
            vm.start()
        }
        .animation(.easeInOut(duration: 0.5), value: vm.mode)
    }
}

// MARK: - GameViewModel
@MainActor
@Observable
class GameViewModel {
    var git = GitState()
    var dialogueEngine = DialogueEngine()
    var mode: GameMode = .story
    var currentMission: Mission? = nil
    var lastResult: CommandResult? = nil
    var commandInput: String = ""
    var commandHistory: [String] = []
    var completedArc: Arc? = nil

    private var allArcs: [Arc] = GameContent.arcs
    private var arcIndex: Int = 0
    private var episodeIndex: Int = 0

    var currentArcNumber: Int { allArcs[safe: arcIndex]?.number ?? 1 }

    private var currentEpisodes: [Episode] {
        allArcs[safe: arcIndex]?.episodes ?? []
    }

    // MARK: - 開始
    func start() {
        let saved = SaveManager.load()
        arcIndex = saved.arcIndex
        episodeIndex = saved.episodeIndex
        loadEpisode()
    }

    // MARK: - エピソード読み込み
    func loadEpisode() {
        guard episodeIndex < currentEpisodes.count else {
            // Arc クリア
            completedArc = allArcs[safe: arcIndex]
            withAnimation { mode = .arcComplete }
            return
        }
        let ep = currentEpisodes[episodeIndex]

        // onLoad セットアップ（ep7 の remote など）
        ep.onLoad?(git)

        dialogueEngine.onFinished = { [weak self] in
            guard let self else { return }
            if let mission = self.currentEpisodes[safe: self.episodeIndex]?.mission {
                withAnimation { self.mode = .mission }
                self.currentMission = mission
                self.commandInput = ""
            } else {
                self.nextEpisode()
            }
        }

        mode = .story
        dialogueEngine.load(ep.lines)
        SaveManager.save(arcIndex: arcIndex, episodeIndex: episodeIndex)
    }

    // MARK: - コマンド送信
    func submitCommand(_ cmd: String) {
        guard let mission = currentMission else { return }

        // ヒストリー追加
        commandHistory.removeAll { $0 == cmd }
        commandHistory.append(cmd)

        let gitResult = git.apply(command: cmd)

        if mission.validate(cmd) {
            lastResult = .success(gitResult.message)
            withAnimation { mode = .result }
        } else {
            lastResult = .failure(mission.failLine.text)
            withAnimation { mode = .result }
        }
        commandInput = ""
    }

    // MARK: - 結果後の処理
    func continueAfterResult() {
        guard let result = lastResult else { return }
        if result.isSuccess {
            if let mission = currentMission {
                dialogueEngine.onFinished = { [weak self] in self?.nextEpisode() }
                mode = .story
                dialogueEngine.load([mission.successLine])
            }
        } else {
            mode = .mission
            commandInput = ""
        }
    }

    // MARK: - 次のArc開始
    func startNextArc() {
        arcIndex += 1
        episodeIndex = 0
        git = GitState()   // Gitステートをリセット
        if arcIndex < allArcs.count {
            completedArc = nil
            loadEpisode()
        }
    }

    private func nextEpisode() {
        episodeIndex += 1
        loadEpisode()
    }
}

