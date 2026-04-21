//
//  MoveValidator.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - MoveValidator

/// Move validator — checks if a specific move is legal.
public struct MoveValidator {

    private let generator = MoveGenerator()

    public init() {}

    /// Is move legal
    public func isLegal(move: Move, in position: Position) -> Bool {
        let legalMoves = generator.generateMoves(for: position)
        return legalMoves.contains { legal in
            legal.from == move.from &&
            legal.to == move.to &&
            legal.promotion == move.promotion
        }
    }

    /// Is move legal (by from/to)
    public func isLegal(from: Square, to: Square, promotion: PieceType? = nil, in position: Position) -> Bool {
        let legalMoves = generator.generateMoves(for: position)
        return legalMoves.contains { legal in
            legal.from == from &&
            legal.to == to &&
            legal.promotion == promotion
        }
    }

    /// Find complete legal Move by from/to
    public func findLegalMove(from: Square, to: Square, promotion: PieceType? = nil, in position: Position) -> Move? {
        let legalMoves = generator.generateMoves(for: position)
        return legalMoves.first { legal in
            legal.from == from &&
            legal.to == to &&
            (promotion == nil || legal.promotion == promotion)
        }
    }

    /// Can piece at square move
    public func canMove(from square: Square, in position: Position) -> Bool {
        !generator.generateMoves(for: position, from: square).isEmpty
    }

    /// Is current player in check
    public func isInCheck(position: Position) -> Bool {
        generator.isInCheck(position: position, color: position.activeColor)
    }

    /// Does current player have legal moves
    public func hasLegalMoves(position: Position) -> Bool {
        !generator.generateMoves(for: position).isEmpty
    }
}
