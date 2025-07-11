//
//  ChessLib.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/1/25.
//

import Foundation

struct Position: Equatable, Hashable {
    let row: Int
    let col: Int
    
    func equals(pos: Position) -> Bool {
        return (row == pos.row && col == pos.col)
    }
}

struct LastMove {
    let from: Position?
    let to: Position?
}

struct BoardUtils {
    
    static func isValid(_ pos: Position) -> Bool {
        return (0..<8).contains(pos.row) && (0..<8).contains(pos.col)
    }

    static func isEmpty(_ pos: Position, in board: [[BoardSquare]]) -> Bool {
        isValid(pos) && getPiece(at: pos, in: board) == nil
    }

    static func isOpponent(at pos: Position, for piece: ChessPiece, in board: [[BoardSquare]]) -> Bool {
        guard isValid(pos), let target = getPiece(at: pos, in: board) else { return false }
        return target.color != piece.color
    }

    static func isAlly(at pos: Position, for piece: ChessPiece, in board: [[BoardSquare]]) -> Bool {
        guard isValid(pos), let target = getPiece(at: pos, in: board) else { return false }
        return target.color == piece.color
    }
    
    static func positionOfKing(for color: PieceColor, in board: [[BoardSquare]]) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = getPiece(at: Position(row: row, col: col), in: board),
                   piece.type == PieceType.King,
                   piece.color == color {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }

    static func isSquareInCheck (at pos:Position, for color: PieceColor, in board: [[BoardSquare]]) -> Bool {
        if let piece = getPiece(at: pos, in: board), piece.color == color, piece.type == .King {
            return GameRules.isKingInCheck(for: color, in: board)
        } else {
            return false
        }
    }
    
    static func getPiece(at pos: Position, in board: [[BoardSquare]]) -> ChessPiece? {
        guard BoardUtils.isValid(pos) else { return nil }
        return board[pos.row][pos.col].piece
    }
}
