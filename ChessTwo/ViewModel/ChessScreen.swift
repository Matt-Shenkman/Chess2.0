//
//  ChessScreen.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/14/25.
//

import Foundation

class ChessScreen: ObservableObject {
    @Published var passAndPlay: Bool = false
    @Published var showLastMove: Bool = false
    init() {
        self.passAndPlay = false
        self.showLastMove = false
    }
    
    func togglePassAndPlay() {
        passAndPlay.toggle()
    }
    
    func toggleLastMove() {
        showLastMove.toggle()
    }
}
