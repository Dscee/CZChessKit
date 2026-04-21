//
//  FEN.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - FEN

/// FEN parsing and generation (Forsyth–Edwards Notation).
/// Формат: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
public enum FEN {

    public static let startingPosition = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    // MARK: - Parse

    /// Parse FEN string to Position
    public static func parse(_ fen: String) -> Position? {
        let parts = fen.split(separator: " ").map(String.init)
        guard parts.count == 6 else { return nil }

        // 1. Pieces on board
        guard let board = parseBoard(parts[0]) else { return nil }

        // 2. Active color
        guard let activeColor = parseColor(parts[1]) else { return nil }

        // 3. Castling rights
        guard let castlingRights = CastlingRights(fen: parts[2]) else { return nil }

        // 4. En passant
        let enPassantSquare: Square?
        if parts[3] == "-" {
            enPassantSquare = nil
        } else {
            guard let square = Square(parts[3]) else { return nil }
            enPassantSquare = square
        }

        // 5. Halfmove clock
        guard let halfmoveClock = Int(parts[4]) else { return nil }

        // 6. Fullmove number
        guard let fullmoveNumber = Int(parts[5]) else { return nil }

        return Position(
            board: board,
            activeColor: activeColor,
            castlingRights: castlingRights,
            enPassantSquare: enPassantSquare,
            halfmoveClock: halfmoveClock,
            fullmoveNumber: fullmoveNumber
        )
    }

    // MARK: - Generate

    /// Generate FEN string from Position
    public static func generate(from position: Position) -> String {
        let parts = [
            generateBoard(position.board),
            position.activeColor == .white ? "w" : "b",
            position.castlingRights.fen,
            position.enPassantSquare?.notation ?? "-",
            String(position.halfmoveClock),
            String(position.fullmoveNumber)
        ]
        return parts.joined(separator: " ")
    }

    // MARK: - Board Parsing

    private static func parseBoard(_ string: String) -> Board? {
        let ranks = string.split(separator: "/").map(String.init)
        guard ranks.count == 8 else { return nil }

        var board = Board()

        for (index, rankString) in ranks.enumerated() {
            let rank = 7 - index // FEN starts from 8th rank
            var file = 0

            for char in rankString {
                if let emptyCount = char.wholeNumberValue {
                    file += emptyCount
                } else if let piece = Piece.from(fen: char) {
                    guard file < 8 else { return nil }
                    board.setPiece(piece, at: Square(file: file, rank: rank))
                    file += 1
                } else {
                    return nil
                }
            }

            guard file == 8 else { return nil }
        }

        return board
    }

    private static func parseColor(_ string: String) -> Color? {
        switch string {
        case "w": return .white
        case "b": return .black
        default: return nil
        }
    }

    // MARK: - Board Generation

    private static func generateBoard(_ board: Board) -> String {
        var ranks: [String] = []

        for rank in stride(from: 7, through: 0, by: -1) {
            var rankString = ""
            var emptyCount = 0

            for file in 0..<8 {
                let square = Square(file: file, rank: rank)
                if let piece = board.piece(at: square) {
                    if emptyCount > 0 {
                        rankString += String(emptyCount)
                        emptyCount = 0
                    }
                    rankString += String(piece.fenSymbol)
                } else {
                    emptyCount += 1
                }
            }

            if emptyCount > 0 {
                rankString += String(emptyCount)
            }

            ranks.append(rankString)
        }

        return ranks.joined(separator: "/")
    }
}
