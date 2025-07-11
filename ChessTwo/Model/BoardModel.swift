//
//  GameState.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 3/29/25.
//

import SwiftUICore


func pieceImageName(for piece: ChessPiece) -> String {
    let colorPrefix = piece.color == .top ? "black" : "white"
    return "\(colorPrefix)\(piece.type.rawValue)"
}

func squareImageName(isDark: Bool, isTarget: Bool) -> String {
    let colorPrefix = isDark ? "dark" : "light"
    let targetPrefix = isTarget ? "Target" : ""
    return "\(colorPrefix)\(targetPrefix)Square"
}

func outcome(gameState: GameState) -> String {
    if gameState == .checkmate {
        return "Checkmate"
    } else if gameState == .resignation {
        return "Resignation"
    } else {
        return "Stalemate"
    }

}


