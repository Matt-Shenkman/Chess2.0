//
//  ChessGameView.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/13/25.
//

import SwiftUI

struct ChessScreenView: View {
    @State private var showMenu = false
    @ObservedObject var screen: ChessScreen
    @StateObject var game: ChessGame

    init(screen: ChessScreen) {
        self.screen = screen
        _game = StateObject(wrappedValue: ChessGame(screen: screen))
    }
    
    var body: some View {

        ZStack {
            VStack(spacing: 12) {
                HStack {
                    // 🖼 Captured pieces at the top
                    CapturedPiecesView(
                        whiteCaptured: game.capturedPieces.whiteCaptured,
                        blackCaptured: game.capturedPieces.blackCaptured
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
                    .padding(.vertical)
                    Spacer()
                    Button("Settings") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showMenu.toggle()
                        }
                    }.padding()
                }
                Spacer()
                

                // ♟️ Main chess board
                ChessBoardView(game: game)
    
                Spacer()
                // 🧠 Optional: Add footer, turn indicator, or controls here
                HStack {
                    Text("\(game.currentTurn == .bottom ? "White" : "Black")'s Turn")
                        .font(.headline)
                        .padding()
                    Spacer()
                    Button("Resign") {
                        game.updateGameState(state: .resignation)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color.cream)
            .overlay(content: {
                if showMenu {
                    Color.black.opacity(0.4)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0)) {
                                showMenu.toggle()
                            }

                        }.edgesIgnoringSafeArea(.all)
                    HStack {
                        Spacer()
                        VStack {
                            Text("Menu")
                                .font(.headline)
                                .padding()
                            HStack {
                                Text("Flip Board")
                                    .padding([.top, .bottom, .leading])
                                Toggle("", isOn: $screen.passAndPlay)
                                    .padding([.top, .bottom, .trailing])

                                Spacer()
                            }
                            HStack {
                                Text("Show Last Move")
                                    .padding([.top, .bottom, .leading])
                                Toggle("", isOn: $screen.showLastMove)
                                .padding()
                                Spacer()
                            }
    
                            Spacer()
                        }
                        .frame(width: UIScreen.main.bounds.width*0.6)
                        .background(Color.white)
                        .transition(.move(edge: .trailing))
                    }
                }
            })
        }
    }
        
}

#Preview {
    ChessScreenView(screen: ChessScreen())
}
 
