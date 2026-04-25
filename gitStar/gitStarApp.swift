//
//  gitStarApp.swift
//  gitStar
//
//  Created by 茂木史明 on 2026/04/25.
//

import SwiftUI

@main
struct gitStarApp: App {
    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunching {
                    LaunchView {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            isLaunching = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: isLaunching)
        }
    }
}
