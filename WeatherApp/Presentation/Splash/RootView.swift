//
//  RootView.swift
//  WeatherApp
//
//  Holds `MainTabView` under an initial splash overlay. Backdrop fills match the
//  app icon gradient endpoints documented in `WeatherReport.icon/icon.json`.
//

import SwiftUI

private enum SplashBackdrop {
    static let light = Color(.sRGB, red: 0.58082, green: 0.08843, blue: 0.31864, opacity: 1)
    static let dark = Color(.sRGB, red: 0.16593, green: 0.02463, blue: 0.09201, opacity: 1)
}

struct RootView: View {
    let deps: WeatherDependencies
    @State private var showSplash = true

    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme

    private var splashBackground: Color {
        colorScheme == .dark ? SplashBackdrop.dark : SplashBackdrop.light
    }

    var body: some View {
        ZStack {
            MainTabView(deps: deps)
                .opacity(showSplash ? 0 : 1)
                .allowsHitTesting(!showSplash)

            if showSplash {
                splashBackground
                    .ignoresSafeArea()
                VStack(spacing: 28) {
                    Spacer()
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 76))
                        .symbolRenderingMode(.multicolor)
                        .accessibilityHidden(true)
                    Text(verbatim: WeatherL10n.string("splash.welcome", locale: locale))
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                        .accessibilityLabel(Text(verbatim: WeatherL10n.string("splash.loading", locale: locale)))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .task {
                    try? await Task.sleep(for: .seconds(1))
                    withAnimation(.easeOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
