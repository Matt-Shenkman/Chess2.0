import SwiftUI

struct CapturedPiecesView: View {
    let whiteCaptured: [ChessPiece]
    let blackCaptured: [ChessPiece]

    let columns = [GridItem(.adaptive(minimum: 20, maximum: 20), spacing: 4)]

    var body: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(blackCaptured, id: \.id) { piece in
                    Image(pieceImageName(for: piece))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.bottom, 4)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(whiteCaptured, id: \.id) { piece in
                    Image(pieceImageName(for: piece))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
