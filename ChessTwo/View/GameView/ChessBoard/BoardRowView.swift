//
//  BoardRowView.swift
//  ChessTwo
//
//  Created by Matt Shenkman on 4/2/25.
//

import SwiftUICore
import SwiftUI

struct BoardRowView: View {
    let row: Int
    let squares: [BoardSquare]
    let squareSize: CGFloat
    let draggingPiece: ChessPiece?
    let dragOffset: CGSize
    let draggingPieceRow: Int
    let legalTargets: [Position]
    let onTap: (Position) -> Void
    let onDragStart: (ChessPiece, Position) -> Void
    let onDragEnd: (DragGesture.Value, CGFloat) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { col in
                BoardSquareView(
                    square: squares[col],
                    squareSize: squareSize,
                    draggingPiece: draggingPiece,
                    dragOffset: dragOffset,
                    legalTargets: legalTargets,
                    onTap: onTap,
                    onDragStart: onDragStart,
                    onDragEnd: onDragEnd
                )
            }
        }
        .zIndex(row == draggingPieceRow ? 100 : 0)
    }
}
