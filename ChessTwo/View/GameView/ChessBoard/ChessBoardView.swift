//
//  ContentView.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 3/29/25.
//

import SwiftUI

struct ChessBoardView: View {
    @ObservedObject var game: ChessGame

    @State private var draggingPiece: ChessPiece? = nil
    @State private var dragOrigin: Position? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var draggingPieceRow = 7

    @State private var showPromotionPicker = false
    @State private var selectedPosition: Position? = nil
    @State private var legalTargets: [Position] = []
    
    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let squareSize = boardSize / 8
            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    rowView(row: row, squareSize: squareSize)
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .rotationEffect(Angle(degrees: game.screen.passAndPlay ? game.currentTurn == .bottom ? 0 : 180: 0))
            .sheet(isPresented: $showPromotionPicker) {
                if var promotion = game.pendingPromotion {
                    PromotionPicker(color: promotion.piece.color) { selectedType in
                        promotion.piece.type = selectedType
                        game.promotePawn(promotion: promotion)
                        game.pendingPromotion = nil
                    }
                }
            }
            .onChange(of: game.pendingPromotion) { oldValue, newValue in
                showPromotionPicker = (newValue != nil)
            }
            .alert(outcome(gameState: game.gameState), isPresented: $game.gameOver) {
                Button("New Game") {
                    game.reset()
                }
            } message: {
                Text("\(game.winner == .top ? "White" : "Black") wins!")
            }
            
        }.background(Color.cream)
        
        
    }
    
    @ViewBuilder
    private func rowView(row: Int, squareSize: CGFloat) -> some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { col in
                    let square = game.board[row][col]
                    squareView(square: square, squareSize: squareSize)
                }
            }
        }
        .zIndex(row == draggingPieceRow ? 100 : 0)
    }
    @ViewBuilder
    private func squareView(square: BoardSquare, squareSize: CGFloat) -> some View {
        let row = square.row
        let col = square.col
        let isDark = (row + col) % 2 == 1
        
        ZStack {
            legalTargets.contains(where: { $0 == Position(row: square.row, col: square.col) }) ?            Image(squareImageName(isDark: isDark, isTarget: true))
                .resizable():
            Image(squareImageName(isDark: isDark, isTarget: false))
                .resizable()
            
            if let piece = square.piece {
                Image(pieceImageName(for: piece))
                    .resizable()
                    .scaledToFit()
                    .frame(width: squareSize * 0.8)
                    .offset(draggingPiece?.id == piece.id ? dragOffset : .zero)
                    .gesture(
                        DragGesture()
                            
                            .onChanged { value in
                                guard piece.color == game.currentTurn else { return }
                                draggingPiece = piece
                                dragOrigin = Position(row: row, col: col)
                                dragOffset = value.translation
                                draggingPieceRow = row
                                handleTap(on: dragOrigin!, skipUpdates: true)
                            }
                            .onEnded { value in
                                handleDrop(value: value, squareSize: squareSize)
                                handleTap(on: dragOrigin!, skipUpdates: true)
                                draggingPiece = nil
                                dragOrigin = nil
                                dragOffset = .zero
                            }
                    )
            }
        }
        .frame(width: squareSize, height: squareSize)
        .zIndex(draggingPiece?.id == square.piece?.id ? 100 : 0)
        .onTapGesture {
            handleTap(on: Position(row: square.row, col: square.col),skipUpdates: false)
        }
        .overlay(
            // Optional: highlight legal move targets
            legalTargets.contains(where: { $0 == Position(row: square.row, col: square.col) }) ?
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.green, lineWidth: 3)
                : nil
        )
        .overlay(
            game.screen.showLastMove && (game.lastMove?.from == Position(row: square.row, col: square.col) || game.lastMove?.to == Position(row: square.row, col: square.col))   ?                 RoundedRectangle(cornerRadius: 4)
                .fill(Color.yellow).opacity(0.15) : nil
        )
        .overlay(
            BoardUtils.isSquareInCheck(at: Position(row: square.row, col: square.col), for: game.currentTurn, in: game.board) ?
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.red).opacity(0.25) : nil
        )
        .rotationEffect(Angle(degrees: game.screen.passAndPlay ? game.currentTurn == .bottom ? 0 : 180: 0))
    }
    
    func handleDrop(value: DragGesture.Value, squareSize: CGFloat) {
        guard let from = dragOrigin,
              let _ = draggingPiece else { return }
        var offsetPos = from
        if game.screen.passAndPlay && game.currentTurn == .top {
            offsetPos = Position(row: 7-from.row,col: 7-from.col)
        }

        let toX = CGFloat(offsetPos.col) * squareSize + value.translation.width
        let toY = CGFloat(offsetPos.row) * squareSize + value.translation.height
        var toCol = Int((toX / squareSize).rounded())
        var toRow = Int((toY / squareSize).rounded())
        
        print(offsetPos, toRow, toCol)
        //Re-invert if needed
        if game.screen.passAndPlay && game.currentTurn == .top {
            toCol = 7-toCol
            toRow = 7-toRow
        }
        
        guard (0..<8).contains(toRow), (0..<8).contains(toCol) else { return }
        
        let legal = game.legalMoves(for: draggingPiece!, from: from, skipKingSafety: false)
        guard legal.contains(where: { $0 == Position(row: toRow, col: toCol) }) else {
            print("Illegal move")
            return
        }
        let to =  Position(row: toRow, col: toCol)
        handleTap(on: to, skipUpdates: true)
        game.movePiece(from: from, to: to)
        // Deselect in all cases
        selectedPosition = nil
        legalTargets = []
    }
    
    func handleTap(on position: Position, skipUpdates: Bool) {
        let square = game.board[position.row][position.col]

        // If a piece is already selected
        if let selected = selectedPosition {
            if (!skipUpdates && selectedPosition!.equals(pos: position)) {
                // reselect target → Deselect
                selectedPosition = nil
                legalTargets = []
                return
            }
            
            if legalTargets.contains(where: { $0 == position }) {
                // ✅ Move to a legal target
                if !skipUpdates {
                    game.movePiece(from: selected, to: position)
                }
                selectedPosition = nil
                legalTargets = []

            } else if let piece = square.piece, piece.color == game.currentTurn {
                // ✅ Change selection to another piece
                selectedPosition = position
                legalTargets = game.legalMoves(for: piece, from: position, skipKingSafety: false)
            } else {
                // ❌ Invalid target → Deselect
                selectedPosition = nil
                legalTargets = []
            }

        } else {
            // No piece selected yet
            guard let piece = square.piece, piece.color == game.currentTurn else { return }

            selectedPosition = position
            legalTargets = game.legalMoves(for: piece, from: position, skipKingSafety: false)
        }
    }
}

struct PromotionPicker: View {
    let color: PieceColor
    let onSelect: (PieceType) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Promote to:")
                .font(.title)

            ForEach([PieceType.Queen, PieceType.Rook, PieceType.Bishop, PieceType.Knight], id: \.self) { type in
                Button(action: {
                    onSelect(type)
                }) {
                    promotionImage(piece: ChessPiece(type: type, color: color))
                }
            }
        }
        .padding()
    }
    
    private func promotionImage(piece: ChessPiece) -> some View {
        let imageName = pieceImageName(for: piece)
        return Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}


#Preview {
    ChessBoardView(game: ChessGame(screen: ChessScreen()))
}
 
