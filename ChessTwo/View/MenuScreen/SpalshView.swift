//
//  SpalshView.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 3/30/25.
//

import Foundation
import SwiftUICore

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            MainMenuView() 
        } else {
            VStack {
                Spacer()
                Image(systemName: "bolt.fill") // Replace with logo or custom image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("Shenkman AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
