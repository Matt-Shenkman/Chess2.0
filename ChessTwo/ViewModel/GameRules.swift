//
//  GameRules.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/1/25.
//

import Foundation

struct GameRules {
    
    static func isKingInCheck(for color: PieceColor, in board: [[BoardSquare]]) -> Bool {
        guard let kingPos = BoardUtils.positionOfKing(for: color, in: board) else {
            return false // no king? technically an error
        }

        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = board[row][col].piece,
                      piece.color != color else { continue }

                let threats = MoveLogic.legalMoves(for: piece, from: Position(row: row, col: col), skipKingSafety: true, enPassantTarget: nil, on: board)
                if threats.contains(where: { $0 == kingPos }) {
                    return true
                }
            }
        }

        return false
    }
    
    static func checkForDemotions(at position: Position, piece: ChessPiece, in board: [[BoardSquare]]) -> [Position] {
        let isSuper = (piece.type == .SuperPawn) || (piece.type == .Pope)
        let isImmune = (piece.type == .King) || (piece.type == .Pawn)
        var demotions: [Position] = []
        for dRow in -1...1 {
            for dCol in -1...1 {
                if dRow == 0 && dCol == 0 { continue }
                let newRow = position.row + dRow
                let newCol = position.col + dCol
                let newPos = Position(row: newRow,col: newCol)
                if BoardUtils.isOpponent(at: newPos, for: piece,in: board) {
                    let target = BoardUtils.getPiece(at: newPos, in: board)
                    let targetSuper = (target?.type == .SuperPawn || target?.type == .Pope)
                    if  !isSuper && !isImmune && targetSuper {
                        return [position]
                    } else if isSuper && !targetSuper {
                        demotions.append(newPos)
                    }
                }
            }
        }
        return demotions
    }
    
    static func checkEndgame(for color: PieceColor, in board: [[BoardSquare]]) -> GameState {
        let inCheck = isKingInCheck(for: color, in: board)
        // If no piece has any legal moves, it's checkmate
        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = board[row][col].piece,
                      piece.color == color else { continue }

                let moves = MoveLogic.legalMoves(for: piece, from: Position(row: row, col: col), skipKingSafety: false, enPassantTarget: nil, on: board)
                
                if !moves.isEmpty {
                    return .active
                }
            }
        }
        return inCheck ? .checkmate : .stalemate
    }
    
    static func squareIsThreatened(_ pos: Position, by opponent: PieceColor, in board: [[BoardSquare]]) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = BoardUtils.getPiece(at: Position(row: row, col: col), in: board), piece.color == opponent {
                    let threats = MoveLogic.legalMoves(for: piece, from: Position(row: row, col: col), skipKingSafety: true, enPassantTarget: nil, on: board)
                    if threats.contains(where: { $0 == pos }) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
