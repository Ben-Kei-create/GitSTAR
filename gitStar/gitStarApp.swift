//
//  gitStarApp.swift
//  gitStar
//

import SwiftUI

@main
struct gitStarApp: App {
    @State private var isLaunching = true
    @State private var startFresh = false   // true = ニューゲーム
    @State private var showPrototype = false  // Arc4 reflog プロトタイプ

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showPrototype {
                    Arc4ReflogPrototype(onExit: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showPrototype = false
                        }
                    })
                    .transition(.opacity)
                } else if isLaunching {
                    LaunchView(
                        onContinue: {
                            startFresh = false
                            withAnimation(.easeInOut(duration: 0.6)) { isLaunching = false }
                        },
                        onNewGame: {
                            startFresh = true
                            withAnimation(.easeInOut(duration: 0.6)) { isLaunching = false }
                        },
                        onPrototype: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showPrototype = true
                            }
                        }
                    )
                    .transition(.opacity)
                } else {
                    ContentView(startFresh: startFresh)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: isLaunching)
            .animation(.easeInOut(duration: 0.5), value: showPrototype)
        }
    }
}
