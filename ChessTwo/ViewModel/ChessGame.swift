//
//  ChessViewController.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 3/29/25.
//

import Foundation

class ChessGame: ObservableObject {
    @Published var board: [[BoardSquare]] = []
    @Published var pendingPromotion: PromotionTarget? = nil
    @Published var enPassantTarget: Position? = nil
    @Published var currentTurn: PieceColor = .bottom
    @Published var winner: PieceColor? = nil
    @Published var gameState: GameState = .active
    @Published var gameOver: Bool = false
    @Published var capturedPieces = CapturedPieces()
    @Published var screen: ChessScreen
    @Published var lastMove: LastMove? = nil
    
    var topCastling = CastlingRights()
    var bottomCastling = CastlingRights()
    
    init(screen : ChessScreen) {
        self.screen = screen
        reset()
    }
    
    func reset() {
        currentTurn = .bottom
        winner = nil
        gameOver = false
        gameState = .active
        topCastling = CastlingRights()
        bottomCastling = CastlingRights()
        capturedPieces = CapturedPieces()
        resetBoard()
    }
    
    func resetBoard() {
        board = Array(repeating: Array(repeating: BoardSquare(row: 0, col: 0, isTarget: false), count: 8), count: 8)
        for row in 0..<8 {
            for col in 0..<8 {
                board[row][col] = BoardSquare(row: row, col: col, isTarget: false)
            }
        }

        setupPieces()
    }
    
    func setupPieces() {
        // Place pawns
        for col in 0..<8 {
            board[1][col].piece = ChessPiece(type: .Pawn, color: .top)
            board[6][col].piece = ChessPiece(type: .Pawn, color: .bottom)
        }
        board[6][3].piece = ChessPiece(type: .SuperPawn, color: .bottom)
        board[1][3].piece = ChessPiece(type: .SuperPawn, color: .top)
        // Place major pieces (e.g. rooks, knights, etc.)
        let backRow: [PieceType] = [.Rook, .Knight, .Bishop, .Queen, .King, .Bishop, .Knight, .Rook]

        for col in 0..<8 {
            board[0][col].piece = ChessPiece(type: backRow[col], color: .top)
            board[7][col].piece = ChessPiece(type: backRow[col], color: .bottom)
        }
    }
    
    func legalMoves(for piece: ChessPiece, from position: Position, skipKingSafety: Bool) -> [Position] {
        var moves = MoveLogic.legalMoves(for: piece, from: position, skipKingSafety: skipKingSafety, enPassantTarget: enPassantTarget, on: board)
        if piece.type == .King && !GameRules.isKingInCheck(for: piece.color,in: board) {
            let rights = piece.color == .top ? topCastling : bottomCastling
            moves += MoveLogic.castlingMoves(for: piece.color, rights: rights, in: board)
        }
        return moves
    }
    
    func movePiece(from: Position, to: Position) {
        // Make sure we're moving from a square with a piece
        guard var movingPiece = BoardUtils.getPiece(at: from, in: board) else {
            return
        }
        var willDemote = false
        var skipEP  = false
        let demotions = GameRules.checkForDemotions(at: to, piece: movingPiece, in: board)
        for demoPos in demotions {
            if demoPos == to {
                capturedPieces.add(movingPiece)
                movingPiece.type = .Pawn
                willDemote = true
            }
            else if var piece = BoardUtils.getPiece(at: demoPos, in: board), piece.type != .King, piece.type != .SuperPawn, piece.type != .Pope {
                piece.type = .Pawn
                updateBoard(movingPiece: piece, to: demoPos, from: demoPos)
            }
        }
        
        if (movingPiece.type == .Knight || movingPiece.type == .Pawn || movingPiece.type == .SuperPawn) && !willDemote {
            movingPiece.type = updatePromotion(movingPiece: movingPiece, to: to)
        }
        
        if movingPiece.type == .Pawn || movingPiece.type == .SuperPawn {
            if abs(to.row - from.row) == 2 {
                let direction = movingPiece.color == .top ? 1 : -1
                enPassantTarget = Position(row: from.row + direction, col: from.col)
                skipEP = true
            } else if enPassantTarget == to {
                 // Remove captured pawn (behind the target)
                let capturedRow = movingPiece.color == .top ? to.row - 1 : to.row + 1
                let targetPos = Position(row: capturedRow, col: to.col)
                updateBoard(movingPiece: nil, to: targetPos, from: targetPos)
            }
        }
        
        if (movingPiece.type == .Rook) {
            var xDir = 0
            var yDir = 0
            let xDiff = to.col - from.col
            let yDiff = to.row - from.row
            if xDiff != 0 {
                xDir = (xDiff)/(abs(xDiff))
            } else {
                yDir = (yDiff)/(abs(yDiff))
            }
            
            for i in 1..<max(abs(xDiff), abs(yDiff)) {
                let clearPos = Position(row: from.row + i * yDir,col: from.col + i * xDir)
                updateBoard(movingPiece: nil, to: clearPos, from: clearPos)
            }
        }

        let rights = movingPiece.color == .top ? topCastling : bottomCastling
        if MoveLogic.castlingMoves(for: movingPiece.color, rights: rights, in: board).contains(to) {
            var piece: ChessPiece?
            var oldPos: Position
            if to.col == 2 {
                oldPos = Position(row: to.row, col: 0)
                piece = BoardUtils.getPiece(at: oldPos, in: board)
                updateBoard(movingPiece: piece, to: Position(row: to.row, col: 3), from: oldPos)
            } else {
                oldPos = Position(row: to.row, col: 7)
                piece = BoardUtils.getPiece(at: oldPos, in: board)
                updateBoard(movingPiece: piece, to: Position(row: to.row, col: 5), from: oldPos)
            }
            updateCastling(movingPiece: piece, from: oldPos)
        }
        if !skipEP {
            enPassantTarget = nil
        }
        
        updateBoard(movingPiece: movingPiece, to: to, from: from)
        updateGameState(state: GameRules.checkEndgame(for: movingPiece.color == .top ? PieceColor.bottom : PieceColor.top, in: board))

    }
    
    func setPendingPromtion(target: PromotionTarget) {
        pendingPromotion = target
    }
    
    func updateBoard(movingPiece: ChessPiece?, to: Position, from: Position) {
        if let capturedPiece = BoardUtils.getPiece(at: to, in: board), movingPiece != capturedPiece, capturedPiece.color != currentTurn {
            capturedPieces.add(capturedPiece)
        }
        board[from.row][from.col].piece = nil
        board[to.row][to.col].piece = movingPiece
        lastMove = LastMove(from: from, to: to)
        updateCastling(movingPiece: movingPiece, from: to)
    }
    
    func updateGameState(state: GameState) {
        gameState = state
        if gameState != .active {
            gameOver = true
            if gameState == .checkmate || gameState == .resignation {
                winner = currentTurn
            }
        } else {
            // Normal turn switch
            currentTurn = (currentTurn == .top) ? .bottom : .top
        }
    }
    
    private func updatePromotion(movingPiece: ChessPiece, to: Position) -> PieceType {
        if ((movingPiece.color == .top && to.row == 7) || (movingPiece.color == .bottom && to.row == 0)) {
            if (movingPiece.type == .Knight) {
                return .Rook
            } else if (movingPiece .type == .SuperPawn){
                return .Pope
            } else {
                // Pause and prompt for promotion
                pendingPromotion = PromotionTarget(position: to, piece: movingPiece)
            }
        }
        //Error something went wrong do not promote
        return movingPiece.type
    }
    
    func updateCastling(movingPiece: ChessPiece?, from: Position) {
        guard let movingPiece = movingPiece else {
            return // No piece passed in
        }
        if movingPiece.type == .King {
            // Update castling rights
            if movingPiece.color == .top {
                topCastling.kingMoved = true
            } else {
                bottomCastling.kingMoved = true
            }
        } else if movingPiece.type == .Rook {
            if from.col == 0 {
                if movingPiece.color == .top {
                    topCastling.queensideRookMoved = true
                } else {
                    bottomCastling.queensideRookMoved = true
                }
            } else if from.col == 7 {
                if movingPiece.color == .top {
                    topCastling.kingsideRookMoved = true
                } else {
                    bottomCastling.kingsideRookMoved = true
                }
            }
        }
    }
    
    func promotePawn(promotion: PromotionTarget) {
        updateBoard(movingPiece: promotion.piece, to:promotion.position,  from: promotion.position)
    }
    

    
    
}
