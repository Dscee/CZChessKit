//
//  SAN.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - SAN

/// Standard Algebraic Notation — human-readable move format (Nf3, O-O, exd5#).
public enum SAN {

    /// Convert Move to SAN string
    /// Requires position for disambiguation (e.g. Rae1 vs Rfe1)
    public static func generate(move: Move, position: Position) -> String {
        // Castling
        if let castling = move.castling {
            let base = castling == .kingside ? "O-O" : "O-O-O"
            return base + suffix(move: move)
        }

        var result = ""

        if move.piece.type != .pawn {
            result += move.piece.type.notation

            // Disambiguation
            let disambig = disambiguation(move: move, position: position)
            result += disambig
        }

        // Capture
        if move.isCapture {
            if move.piece.type == .pawn {
                result += fileNotation(move.from.file)
            }
            result += "x"
        }

        // Destination square
        result += move.to.notation

        // Promotion
        if let promotion = move.promotion {
            result += "=\(promotion.notation)"
        }

        result += suffix(move: move)

        return result
    }

    /// Parse SAN string to Move (requires position to determine from/to)
    public static func parse(_ san: String, position: Position) -> Move? {
        let generator = MoveGenerator()
        let legalMoves = generator.generateMoves(for: position)

        // Castling
        if san.hasPrefix("O-O-O") || san.hasPrefix("0-0-0") {
            return legalMoves.first { $0.castling == .queenside }
        }
        if san.hasPrefix("O-O") || san.hasPrefix("0-0") {
            return legalMoves.first { $0.castling == .kingside }
        }

        // Remove suffixes
        var cleaned = san
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: "?", with: "")

        // Promotion (e8=Q)
        var promotionType: PieceType?
        if let eqRange = cleaned.range(of: "=") {
            let promoChar = cleaned[cleaned.index(after: eqRange.lowerBound)]
            promotionType = pieceType(from: promoChar)
            cleaned = String(cleaned[cleaned.startIndex..<eqRange.lowerBound])
        }

        // Piece type
        var pieceType: PieceType = .pawn
        var remaining = cleaned

        if let first = remaining.first, first.isUppercase {
            if let pt = Self.pieceType(from: first) {
                pieceType = pt
                remaining = String(remaining.dropFirst())
            }
        }

        // Capture
        remaining = remaining.replacingOccurrences(of: "x", with: "")

        // Destination square — last 2 characters
        guard remaining.count >= 2 else { return nil }
        let toNotation = String(remaining.suffix(2))
        guard let toSquare = Square(toNotation) else { return nil }
        remaining = String(remaining.dropLast(2))

        // Disambiguation
        var disambigFile: Int?
        var disambigRank: Int?
        for char in remaining {
            if char >= "a" && char <= "h" {
                disambigFile = Int(char.asciiValue! - Character("a").asciiValue!)
            } else if char >= "1" && char <= "8" {
                disambigRank = Int(String(char))! - 1
            }
        }

        // Find matching legal move
        let matching = legalMoves.filter { move in
            guard move.piece.type == pieceType else { return false }
            guard move.to == toSquare else { return false }
            if let promo = promotionType {
                guard move.promotion == promo else { return false }
            }
            if let file = disambigFile {
                guard move.from.file == file else { return false }
            }
            if let rank = disambigRank {
                guard move.from.rank == rank else { return false }
            }
            return true
        }

        return matching.count == 1 ? matching[0] : nil
    }

    // MARK: - Private

    private static func disambiguation(move: Move, position: Position) -> String {
        // Find other pieces of same type and color that can move to same square
        let sameTypePieces = position.board.squares(of: move.piece.type, color: move.piece.color)
        let generator = MoveGenerator()

        let ambiguous = sameTypePieces.filter { square in
            guard square != move.from else { return false }
            let allMoves = generator.generateMoves(for: position)
            return allMoves.contains { $0.from == square && $0.to == move.to && $0.piece.type == move.piece.type }
        }

        guard !ambiguous.isEmpty else { return "" }

        let sameFile = ambiguous.filter { $0.file == move.from.file }
        let sameRank = ambiguous.filter { $0.rank == move.from.rank }

        if sameFile.isEmpty {
            return fileNotation(move.from.file)
        } else if sameRank.isEmpty {
            return String(move.from.rank + 1)
        } else {
            return move.from.notation
        }
    }

    private static func suffix(move: Move) -> String {
        if move.isCheckmate { return "#" }
        if move.isCheck { return "+" }
        return ""
    }

    private static func fileNotation(_ file: Int) -> String {
        String(Character(UnicodeScalar(Int(Character("a").asciiValue!) + file)!))
    }

    private static func pieceType(from char: Character) -> PieceType? {
        switch char.uppercased() {
        case "K": return .king
        case "Q": return .queen
        case "R": return .rook
        case "B": return .bishop
        case "N": return .knight
        default: return nil
        }
    }
}
