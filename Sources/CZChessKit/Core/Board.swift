//
//  Board.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - Board

/// Board — pure map of pieces on squares.
/// Does not contain game state (turn, castling, etc.) — that's in Position.
public struct Board: Equatable, Hashable, Codable, Sendable {

    /// 64 squares, indexed as [rank * 8 + file]
    private var squares: [Piece?]

    public init() {
        squares = Array(repeating: nil, count: 64)
    }

    // MARK: - Piece access

    private func index(for square: Square) -> Int {
        square.rank * 8 + square.file
    }

    /// Piece at square
    public func piece(at square: Square) -> Piece? {
        squares[index(for: square)]
    }

    /// Set piece at square
    public mutating func setPiece(_ piece: Piece?, at square: Square) {
        squares[index(for: square)] = piece
    }

    /// Remove piece from square, return it
    @discardableResult
    public mutating func removePiece(at square: Square) -> Piece? {
        let piece = self.piece(at: square)
        setPiece(nil, at: square)
        return piece
    }

    /// Move piece from one square to another
    public mutating func movePiece(from: Square, to: Square) {
        let piece = removePiece(at: from)
        setPiece(piece, at: to)
    }

    // MARK: - Search

    /// All squares with pieces of a certain color
    public func squares(for color: Color) -> [(square: Square, piece: Piece)] {
        var result: [(Square, Piece)] = []
        for square in Square.all {
            if let piece = piece(at: square), piece.color == color {
                result.append((square, piece))
            }
        }
        return result
    }

    /// Find king of a certain color
    public func kingSquare(for color: Color) -> Square? {
        let king = Piece(type: .king, color: color)
        return Square.all.first { piece(at: $0) == king }
    }

    /// All squares with specific piece type and color
    public func squares(of type: PieceType, color: Color) -> [Square] {
        let target = Piece(type: type, color: color)
        return Square.all.filter { piece(at: $0) == target }
    }

    /// Is square empty
    public func isEmpty(at square: Square) -> Bool {
        piece(at: square) == nil
    }

    /// Is occupied by piece of certain color
    public func isOccupied(at square: Square, by color: Color) -> Bool {
        piece(at: square)?.color == color
    }

    // MARK: - Initial position

    public static let initial: Board = {
        var board = Board()

        // White pieces
        board.setPiece(Piece(type: .rook,   color: .white), at: .a1)
        board.setPiece(Piece(type: .knight, color: .white), at: .b1)
        board.setPiece(Piece(type: .bishop, color: .white), at: .c1)
        board.setPiece(Piece(type: .queen,  color: .white), at: .d1)
        board.setPiece(Piece(type: .king,   color: .white), at: .e1)
        board.setPiece(Piece(type: .bishop, color: .white), at: .f1)
        board.setPiece(Piece(type: .knight, color: .white), at: .g1)
        board.setPiece(Piece(type: .rook,   color: .white), at: .h1)

        // White pawns
        for file in 0..<8 {
            board.setPiece(Piece(type: .pawn, color: .white), at: Square(file: file, rank: 1))
        }

        // Black pieces
        board.setPiece(Piece(type: .rook,   color: .black), at: .a8)
        board.setPiece(Piece(type: .knight, color: .black), at: .b8)
        board.setPiece(Piece(type: .bishop, color: .black), at: .c8)
        board.setPiece(Piece(type: .queen,  color: .black), at: .d8)
        board.setPiece(Piece(type: .king,   color: .black), at: .e8)
        board.setPiece(Piece(type: .bishop, color: .black), at: .f8)
        board.setPiece(Piece(type: .knight, color: .black), at: .g8)
        board.setPiece(Piece(type: .rook,   color: .black), at: .h8)

        // Black pawns
        for file in 0..<8 {
            board.setPiece(Piece(type: .pawn, color: .black), at: Square(file: file, rank: 6))
        }

        return board
    }()

    /// Empty board
    public static let empty = Board()
}

// MARK: - CustomStringConvertible

extension Board: CustomStringConvertible {
    /// Text representation of the board (for debugging)
    public var description: String {
        var result = ""
        for rank in stride(from: 7, through: 0, by: -1) {
            result += "\(rank + 1) "
            for file in 0..<8 {
                let square = Square(file: file, rank: rank)
                if let piece = piece(at: square) {
                    result += "\(piece.fenSymbol) "
                } else {
                    result += ". "
                }
            }
            result += "\n"
        }
        result += "  a b c d e f g h"
        return result
    }
}
