//
//  Move.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - Move

public struct Move: Equatable, Hashable, Codable {
    /// From square
    public let from: Square
    /// To square
    public let to: Square
    /// Moving piece
    public let piece: Piece

    // MARK: - Flags

    /// Captured piece (if any)
    public let capturedPiece: Piece?
    /// Pawn promotion (if any)
    public let promotion: PieceType?
    /// Castling (if any)
    public let castling: CastlingSide?
    /// En passant capture
    public let isEnPassant: Bool
    /// Check
    public let isCheck: Bool
    /// Checkmate
    public let isCheckmate: Bool

    public init(
        from: Square,
        to: Square,
        piece: Piece,
        capturedPiece: Piece? = nil,
        promotion: PieceType? = nil,
        castling: CastlingSide? = nil,
        isEnPassant: Bool = false,
        isCheck: Bool = false,
        isCheckmate: Bool = false
    ) {
        self.from = from
        self.to = to
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.promotion = promotion
        self.castling = castling
        self.isEnPassant = isEnPassant
        self.isCheck = isCheck
        self.isCheckmate = isCheckmate
    }

    /// Is capture
    public var isCapture: Bool {
        capturedPiece != nil
    }

    /// Is promotion
    public var isPromotion: Bool {
        promotion != nil
    }

    /// UCI notation (e2e4, e7e8q)
    public var uci: String {
        var result = from.notation + to.notation
        if let promotion {
            result += String(promotion.fenSymbol(for: .black)) // UCI always lowercase
        }
        return result
    }

    /// SAN notation (Nf3, exd5, O-O, e8=Q+)
    /// Note: full SAN requires position context for disambiguation
    public var san: String {
        // Castling
        if let castling {
            let base = castling == .kingside ? "O-O" : "O-O-O"
            return base + sanSuffix
        }

        var result = ""

        // Piece symbol
        if piece.type != .pawn {
            result += piece.type.notation
        }

        // Capture (for pawn add file)
        if isCapture {
            if piece.type == .pawn {
                result += String(from.notation.first!)
            }
            result += "x"
        }

        // Destination square
        result += to.notation

        // Promotion
        if let promotion {
            result += "=\(promotion.notation)"
        }

        result += sanSuffix

        return result
    }

    private var sanSuffix: String {
        if isCheckmate { return "#" }
        if isCheck { return "+" }
        return ""
    }
}

extension Move: CustomStringConvertible {
    public var description: String { san }
}
