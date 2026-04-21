//
//  UCI.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - UCI

/// Universal Chess Interface — machine move format (e2e4, e7e8q).
public enum UCI {

    /// Parse UCI string to Move (requires position)
    public static func parse(_ uci: String, position: Position) -> Move? {
        guard uci.count >= 4 else { return nil }

        let chars = Array(uci)
        let fromNotation = String(chars[0...1])
        let toNotation = String(chars[2...3])

        guard let from = Square(fromNotation),
              let to = Square(toNotation) else { return nil }

        // Promotion
        var promotion: PieceType?
        if chars.count == 5 {
            promotion = pieceType(from: chars[4])
        }

        guard let piece = position.board.piece(at: from) else { return nil }

        let capturedPiece = position.board.piece(at: to)

        // En passant
        let isEnPassant = piece.type == .pawn &&
            to == position.enPassantSquare &&
            from.file != to.file

        // Castling
        var castling: CastlingSide?
        if piece.type == .king {
            let fileDiff = to.file - from.file
            if fileDiff == 2 { castling = .kingside }
            if fileDiff == -2 { castling = .queenside }
        }

        // To determine check/checkmate need to apply move
        let newPosition = position.applying(
            Move(from: from, to: to, piece: piece, capturedPiece: capturedPiece,
                 promotion: promotion, castling: castling, isEnPassant: isEnPassant)
        )

        let generator = MoveGenerator()
        let isCheck = generator.isInCheck(position: newPosition, color: newPosition.activeColor)
        let isCheckmate = isCheck && generator.generateMoves(for: newPosition).isEmpty

        return Move(
            from: from,
            to: to,
            piece: piece,
            capturedPiece: isEnPassant ? Piece(type: .pawn, color: piece.color.opposite) : capturedPiece,
            promotion: promotion,
            castling: castling,
            isEnPassant: isEnPassant,
            isCheck: isCheck,
            isCheckmate: isCheckmate
        )
    }

    /// Generate UCI string from Move
    public static func generate(from move: Move) -> String {
        move.uci
    }

    // MARK: - Private

    private static func pieceType(from char: Character) -> PieceType? {
        switch char.lowercased() {
        case "q": return .queen
        case "r": return .rook
        case "b": return .bishop
        case "n": return .knight
        default: return nil
        }
    }
}
