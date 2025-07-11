//
//  ChessPiece.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 3/29/25.
//

import Foundation

enum PieceType: String {
    case King, Queen, Rook, Bishop, Knight, Pawn, SuperPawn, Pope
}

enum PieceColor {
    case top, bottom
}

struct ChessPiece: Equatable {
    let id = UUID()
    var type: PieceType
    let color: PieceColor
}
struct PromotionTarget: Equatable {
    let position: Position
    var piece: ChessPiece
}


struct BoardSquare: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    var piece: ChessPiece? = nil
    var isTarget: Bool
}

struct CastlingRights {
    var kingMoved = false
    var kingsideRookMoved = false
    var queensideRookMoved = false
}

enum GameState {
    case active, checkmate, stalemate, resignation
}
