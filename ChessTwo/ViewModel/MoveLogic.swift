//
//  MoveLogic.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/1/25.
//

import Foundation

class MoveLogic {
    
    static func legalMoves(for piece: ChessPiece, from position: Position, skipKingSafety: Bool, enPassantTarget: Position?, on board: [[BoardSquare]]) -> [Position] {
        var moves: [Position] = []

        switch piece.type {
            case .Pawn:
            moves += pawnMovement(piece: piece, from: position, enPassant: enPassantTarget, in: board)
            
            case .SuperPawn:
            moves += pawnMovement(piece: piece, from: position, enPassant: enPassantTarget, in: board)
            
            case .Pope:
                let offsets = [
                    (1,0), (-1,0), (0,1), (0,-1),
                    (1,1), (-1,-1), (1,-1), (-1,1)
                ]
                moves += offsetMoves(from: position, offsets: offsets, for: piece, requireEmpty: false, in: board)
            
            case .Rook:
                moves += linearMoves(from: position, directions: [(1,0), (-1,0), (0,1), (0,-1)], for: piece, in: board)
            
            case .Bishop:
                moves += linearMoves(from: position, directions: [(1,1), (-1,-1), (1,-1), (-1,1)], for: piece, in: board)
            
                //Empty Adjacent Orthogonal Squares
                let offsets = [(0, -1), (0, 1), (-1, 0), (1, 0)] // left, right, up, down
                moves += offsetMoves(from: position, offsets: offsets, for: piece, requireEmpty: true, in: board)

            case .Queen:
                moves += linearMoves(from: position, directions: [
                    (1,0), (-1,0), (0,1), (0,-1),
                    (1,1), (-1,-1), (1,-1), (-1,1)
                ], for: piece, in: board)

            case .Knight:
                let offsets = [(2,1), (1,2), (-1,2), (-2,1), (-2,-1), (-1,-2), (1,-2), (2,-1)]
                moves += offsetMoves(from: position, offsets: offsets, for: piece, requireEmpty: false, in: board)

            case .King:
                let offsets = [
                    (1,0), (-1,0), (0,1), (0,-1),
                    (1,1), (-1,-1), (1,-1), (-1,1)
                ]
                moves += offsetMoves(from: position, offsets: offsets, for: piece, requireEmpty: false, in: board)
            

        }
        if !skipKingSafety {
            moves = moves.filter { move in
                isMoveLegal(piece, from: position, to: move, in: board)
            }
        }

        return moves.filter(BoardUtils.isValid)
    }
    
    private static func isMoveLegal(_ piece: ChessPiece, from position: Position, to move: Position, in board: [[BoardSquare]]) -> Bool {
        // Make a deep copy of the board
        var simulatedBoard = board

        // Simulate the move
        simulatedBoard[move.row][move.col].piece = piece
        simulatedBoard[position.row][position.col].piece = nil

        // Check if king is in check *after* the move
        let inCheck = GameRules.isKingInCheck(for: piece.color, in: simulatedBoard)

        return !inCheck
    }

    private static func linearMoves(from position: Position, directions: [(Int, Int)], for piece: ChessPiece, in board: [[BoardSquare]]) -> [Position] {
        var moves: [Position] = []
        for (dr, dc) in directions {
            var count = 0
            var r = position.row + dr
            var c = position.col + dc
            var pos = Position(row: r, col: c)
            while BoardUtils.isValid(pos) {
                if piece.type == .Rook && count >= 3 {
                    break
                }
                if BoardUtils.getPiece(at: pos, in: board) == nil {
                    moves.append(pos)
                } else {
                    if BoardUtils.isOpponent(at: pos, for: piece, in: board) {
                        moves.append(pos)
                        if piece.type != .Rook {
                            break
                        }
                    } else {
                        break
                    }

                }
                r += dr
                c += dc
                count += 1
                pos = Position(row: r, col: c)
            }
        }
        return moves
    }

    private static func pawnMovement(piece : ChessPiece, from position: Position, enPassant: Position?, in board: [[BoardSquare]]) -> [Position]  {
        var moves: [Position] = []
        let direction = (piece.color == .top) ? 1 : -1
        let startRow = (piece.color == .top) ? 1 : 6
        let oneStep = Position(row: position.row + direction, col: position.col)
        let twoStep = Position(row: position.row + 2 * direction, col: position.col)

        // Forward move
        if BoardUtils.isEmpty(oneStep, in: board) {
            moves.append(oneStep)
            // Double move from starting position
            if position.row == startRow && BoardUtils.isEmpty(twoStep, in: board) {
                moves.append(twoStep)
            }
        }

        // Diagonal captures
        for yOffset in [-1, 1] {
            for xOffset in [-1, 1] {
                let target = Position(row: position.row + yOffset*direction, col: position.col + xOffset)
                if BoardUtils.isOpponent(at: target, for: piece, in: board) {
                    moves.append(target)
                } else if target == enPassant {
                    moves.append(target)
                }
            }
        }
        return moves
    }
    
    private static func offsetMoves(from position: Position, offsets: [(Int, Int)], for piece: ChessPiece, requireEmpty: Bool, in board: [[BoardSquare]]) -> [Position] {
        var moves: [Position] = []

        for (dy, dx) in offsets {
            let dest = Position(row: position.row + dy, col: position.col + dx)
            //check valid, not occupied by ally and optionally check empty if required paramtetr is true
            if BoardUtils.isValid(dest) && !BoardUtils.isAlly(at: dest, for: piece, in: board) && (!requireEmpty || BoardUtils.isEmpty(dest, in: board)) {
                moves.append(dest)
            }
        }

        return moves
    }
    
    static func castlingMoves(for color: PieceColor, rights: CastlingRights, in board: [[BoardSquare]]) -> [Position] {
        let row = (color == .top) ? 0 : 7
        let opponent : PieceColor = (color == .top) ? .bottom : .top
        var results: [Position] = []


        // Kingside
        if !rights.kingMoved && !rights.kingsideRookMoved &&
            BoardUtils.getPiece(at: Position(row: row, col: 5), in: board) == nil &&
            BoardUtils.getPiece(at: Position(row: row, col: 6), in: board) == nil &&
            !GameRules.squareIsThreatened(Position(row: row, col: 5), by: opponent, in: board) &&
            !GameRules.squareIsThreatened(Position(row: row, col: 6), by: opponent, in: board) {
            results.append(Position(row: row, col: 6)) // King moves two spaces right
        }

        // Queenside
        if !rights.kingMoved && !rights.queensideRookMoved &&
            BoardUtils.getPiece(at: Position(row: row, col: 3), in: board) == nil &&
            BoardUtils.getPiece(at: Position(row: row, col: 2), in: board) == nil &&
            BoardUtils.getPiece(at: Position(row: row, col: 1), in: board) == nil &&
            !GameRules.squareIsThreatened(Position(row: row, col: 3), by: opponent, in: board) &&
            !GameRules.squareIsThreatened(Position(row: row, col: 2), by: opponent, in: board) &&
            !GameRules.squareIsThreatened(Position(row: row, col: 1), by: opponent, in: board){
            results.append(Position(row: row, col: 2)) // King moves two spaces left
        }

        return results
    }
    

}
