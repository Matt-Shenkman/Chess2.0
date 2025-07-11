import Foundation
import SwiftUI

class CapturedPieces: ObservableObject {
    @Published var whiteCaptured: [ChessPiece] = []
    @Published var blackCaptured: [ChessPiece] = []

    func add(_ piece: ChessPiece) {
        if piece.color == .bottom {
            whiteCaptured.append(piece)
        } else {
            blackCaptured.append(piece)
        }
    }

    func reset() {
        whiteCaptured = []
        blackCaptured = []
    }
}
