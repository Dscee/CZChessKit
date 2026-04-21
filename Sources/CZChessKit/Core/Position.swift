//
//  Position.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - Position

/// Full position state — everything needed to determine legal moves.
/// Equivalent to FEN string.
public struct Position: Equatable, Hashable, Codable, Sendable {

    /// Piece placement
    public var board: Board

    /// Active color
    public var activeColor: Color

    /// Castling rights
    public var castlingRights: CastlingRights

    /// En passant target square (or nil)
    public var enPassantSquare: Square?

    /// Halfmove clock without capture or pawn move (for 50-move rule)
    public var halfmoveClock: Int

    /// Fullmove number (starts at 1, increments after black's move)
    public var fullmoveNumber: Int

    public init(
        board: Board = .initial,
        activeColor: Color = .white,
        castlingRights: CastlingRights = .initial,
        enPassantSquare: Square? = nil,
        halfmoveClock: Int = 0,
        fullmoveNumber: Int = 1
    ) {
        self.board = board
        self.activeColor = activeColor
        self.castlingRights = castlingRights
        self.enPassantSquare = enPassantSquare
        self.halfmoveClock = halfmoveClock
        self.fullmoveNumber = fullmoveNumber
    }

    /// Starting position
    public static let initial = Position()

    // MARK: - Applying move

    /// Returns new position after applying move
    public func applying(_ move: Move) -> Position {
        var newPosition = self

        // Move piece
        newPosition.board.removePiece(at: move.from)

        // If promotion — place new piece, otherwise original
        if let promotion = move.promotion {
            newPosition.board.setPiece(
                Piece(type: promotion, color: move.piece.color),
                at: move.to
            )
        } else {
            newPosition.board.setPiece(move.piece, at: move.to)
        }

        // En passant — remove pawn
        if move.isEnPassant {
            let capturedPawnRank = move.piece.color == .white ? move.to.rank - 1 : move.to.rank + 1
            let capturedSquare = Square(file: move.to.file, rank: capturedPawnRank)
            newPosition.board.removePiece(at: capturedSquare)
        }

        // Castling — move rook
        if let castling = move.castling {
            let rank = move.piece.color == .white ? 0 : 7
            switch castling {
            case .kingside:
                newPosition.board.movePiece(
                    from: Square(file: 7, rank: rank),
                    to: Square(file: 5, rank: rank)
                )
            case .queenside:
                newPosition.board.movePiece(
                    from: Square(file: 0, rank: rank),
                    to: Square(file: 3, rank: rank)
                )
            }
        }

        // Update castling rights
        newPosition.updateCastlingRights(after: move)

        // Update en passant
        newPosition.enPassantSquare = nil
        if move.piece.type == .pawn {
            let rankDiff = abs(move.to.rank - move.from.rank)
            if rankDiff == 2 {
                let epRank = (move.from.rank + move.to.rank) / 2
                newPosition.enPassantSquare = Square(file: move.from.file, rank: epRank)
            }
        }

        // Update halfmove clock
        if move.piece.type == .pawn || move.isCapture {
            newPosition.halfmoveClock = 0
        } else {
            newPosition.halfmoveClock += 1
        }

        // Update fullmove number
        if activeColor == .black {
            newPosition.fullmoveNumber += 1
        }

        // Switch turn
        newPosition.activeColor = activeColor.opposite

        return newPosition
    }

    // MARK: - Private

    private mutating func updateCastlingRights(after move: Move) {
        // If king moves — remove all rights
        if move.piece.type == .king {
            castlingRights.removeAll(for: move.piece.color)
        }

        // If rook moves — remove corresponding right
        if move.piece.type == .rook {
            switch (move.piece.color, move.from) {
            case (.white, .a1): castlingRights.whiteQueenside = false
            case (.white, .h1): castlingRights.whiteKingside = false
            case (.black, .a8): castlingRights.blackQueenside = false
            case (.black, .h8): castlingRights.blackKingside = false
            default: break
            }
        }

        // If rook captured — remove right
        if move.isCapture {
            switch move.to {
            case .a1: castlingRights.whiteQueenside = false
            case .h1: castlingRights.whiteKingside = false
            case .a8: castlingRights.blackQueenside = false
            case .h8: castlingRights.blackKingside = false
            default: break
            }
        }
    }
}
