//
//  gitStarApp.swift
//  gitStar
//

import SwiftUI

@main
struct gitStarApp: App {
    @State private var isLaunching = true
    @State private var startFresh = false   // true = ニューゲーム

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunching {
                    LaunchView(
                        onContinue: {
                            startFresh = false
                            withAnimation(.easeInOut(duration: 0.6)) { isLaunching = false }
                        },
                        onNewGame: {
                            startFresh = true
                            withAnimation(.easeInOut(duration: 0.6)) { isLaunching = false }
                        }
                    )
                    .transition(.opacity)
                } else {
                    ContentView(startFresh: startFresh)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: isLaunching)
        }
    }
}
