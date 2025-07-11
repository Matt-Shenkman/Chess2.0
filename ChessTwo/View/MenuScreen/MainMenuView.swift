//
//  MainMenuView.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/13/25.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()

                Text("Chess 2.0")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 20) {
                    NavigationLink(destination: ChessScreenView(screen: ChessScreen())) {
                        menuButtonLabel("Play Game")
                    }

                    NavigationLink(destination: SettingsView()) {
                        menuButtonLabel("Settings")
                    }

                    NavigationLink(destination: AboutView()) {
                        menuButtonLabel("About")
                    }
                }

                Spacer()

                Text("Shenkman AI - Chess 2.0™ v1.0")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.cream)
            .ignoresSafeArea()
        }
    }

    func menuButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

struct AboutView: View {
    var body: some View {
        Text("Made with ❤️ by Shenkman AI")
            .font(.title2)
    }
}

#Preview {
    MainMenuView()
}
