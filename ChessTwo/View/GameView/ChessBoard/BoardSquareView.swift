//
//  BoardSquareView.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/2/25.
//

import SwiftUICore
import SwiftUI

struct BoardSquareView: View {
    let square: BoardSquare
    let squareSize: CGFloat
    let draggingPiece: ChessPiece?
    let dragOffset: CGSize
    let legalTargets: [Position]
    let onTap: (Position) -> Void
    let onDragStart: (ChessPiece, Position) -> Void
    let onDragEnd: (DragGesture.Value, CGFloat) -> Void

    var body: some View {
        let isDark = (square.row + square.col) % 2 == 1
        let pos = Position(row: square.row, col: square.col)

        ZStack {
            Image(squareImageName(isDark: isDark, isTarget: legalTargets.contains(pos)))
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
                                onDragStart(piece, pos)
                            }
                            .onEnded { value in
                                onDragEnd(value, squareSize)
                            }
                    )
            }
        }
        .frame(width: squareSize, height: squareSize)
        .zIndex(draggingPiece?.id == square.piece?.id ? 100 : 0)
        .onTapGesture {
            onTap(pos)
        }
        .overlay(
            legalTargets.contains(pos) ?
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.green, lineWidth: 3)
                : nil
        )
    }
}
