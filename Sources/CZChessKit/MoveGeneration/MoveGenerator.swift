//
//  MoveGenerator.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - MoveGenerator

/// Legal move generator for position.
public struct MoveGenerator {

    public init() {}

    // MARK: - Public API

    /// All legal moves for current position
    public func generateMoves(for position: Position) -> [Move] {
        let color = position.activeColor
        let pseudoLegal = generatePseudoLegalMoves(for: position, color: color)

        // Filter moves that leave king in check
        return pseudoLegal.compactMap { move in
            let newPosition = position.applying(move)
            // Check if king is not in check after move
            guard !isInCheck(position: newPosition, color: color) else { return nil }

            // Add check/checkmate flags
            let opponentColor = color.opposite
            let opponentInCheck = isInCheck(position: newPosition, color: opponentColor)
            let opponentHasMoves = !generatePseudoLegalMoves(for: newPosition, color: opponentColor)
                .contains { pseudoMove in
                    let afterOpponent = newPosition.applying(pseudoMove)
                    return !isInCheck(position: afterOpponent, color: opponentColor)
                }

            let isCheckmate = opponentInCheck && opponentHasMoves

            if opponentInCheck || isCheckmate {
                return Move(
                    from: move.from,
                    to: move.to,
                    piece: move.piece,
                    capturedPiece: move.capturedPiece,
                    promotion: move.promotion,
                    castling: move.castling,
                    isEnPassant: move.isEnPassant,
                    isCheck: opponentInCheck,
                    isCheckmate: isCheckmate
                )
            }

            return move
        }
    }

    /// Legal moves for specific piece at square
    public func generateMoves(for position: Position, from square: Square) -> [Move] {
        generateMoves(for: position).filter { $0.from == square }
    }

    /// Is king of certain color in check
    public func isInCheck(position: Position, color: Color) -> Bool {
        guard let kingSquare = position.board.kingSquare(for: color) else {
            return false
        }
        return isSquareAttacked(position: position, square: kingSquare, by: color.opposite)
    }

    /// Is square attacked by pieces of certain color
    public func isSquareAttacked(position: Position, square: Square, by color: Color) -> Bool {
        let board = position.board

        // Check pawn attack
        let pawnDirection = color == .white ? -1 : 1
        for deltaFile in [-1, 1] {
            if let attackSquare = square.offset(deltaFile: deltaFile, deltaRank: pawnDirection) {
                if let piece = board.piece(at: attackSquare),
                   piece == Piece(type: .pawn, color: color) {
                    return true
                }
            }
        }

        // Check knight attack
        let knightOffsets = [
            (-2, -1), (-2, 1), (-1, -2), (-1, 2),
            (1, -2), (1, 2), (2, -1), (2, 1)
        ]
        for (df, dr) in knightOffsets {
            if let attackSquare = square.offset(deltaFile: df, deltaRank: dr) {
                if let piece = board.piece(at: attackSquare),
                   piece == Piece(type: .knight, color: color) {
                    return true
                }
            }
        }

        // Check diagonal attack (bishop, queen)
        let diagonalDirections = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        for (df, dr) in diagonalDirections {
            if let attacker = firstPieceInDirection(board: board, from: square, deltaFile: df, deltaRank: dr) {
                if attacker.piece.color == color &&
                   (attacker.piece.type == .bishop || attacker.piece.type == .queen) {
                    return true
                }
            }
        }

        // Check straight attack (rook, queen)
        let straightDirections = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        for (df, dr) in straightDirections {
            if let attacker = firstPieceInDirection(board: board, from: square, deltaFile: df, deltaRank: dr) {
                if attacker.piece.color == color &&
                   (attacker.piece.type == .rook || attacker.piece.type == .queen) {
                    return true
                }
            }
        }

        // Check king attack
        let kingOffsets = [
            (-1, -1), (-1, 0), (-1, 1), (0, -1),
            (0, 1), (1, -1), (1, 0), (1, 1)
        ]
        for (df, dr) in kingOffsets {
            if let attackSquare = square.offset(deltaFile: df, deltaRank: dr) {
                if let piece = board.piece(at: attackSquare),
                   piece == Piece(type: .king, color: color) {
                    return true
                }
            }
        }

        return false
    }

    // MARK: - Pseudo-Legal Move Generation

    private func generatePseudoLegalMoves(for position: Position, color: Color) -> [Move] {
        var moves: [Move] = []
        let pieces = position.board.squares(for: color)

        for (square, piece) in pieces {
            switch piece.type {
            case .pawn:   moves += generatePawnMoves(position: position, from: square, piece: piece)
            case .knight: moves += generateKnightMoves(position: position, from: square, piece: piece)
            case .bishop: moves += generateBishopMoves(position: position, from: square, piece: piece)
            case .rook:   moves += generateRookMoves(position: position, from: square, piece: piece)
            case .queen:  moves += generateQueenMoves(position: position, from: square, piece: piece)
            case .king:   moves += generateKingMoves(position: position, from: square, piece: piece)
            }
        }

        return moves
    }

    // MARK: - Piece-Specific Generation

    private func generatePawnMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        var moves: [Move] = []
        let board = position.board
        let color = piece.color
        let direction = color == .white ? 1 : -1
        let startRank = color == .white ? 1 : 6
        let promotionRank = color == .white ? 7 : 0

        // Move forward
        if let oneStep = from.offset(deltaFile: 0, deltaRank: direction),
           board.isEmpty(at: oneStep) {

            if oneStep.rank == promotionRank {
                // Promotion
                for promoType in [PieceType.queen, .rook, .bishop, .knight] {
                    moves.append(Move(from: from, to: oneStep, piece: piece, promotion: promoType))
                }
            } else {
                moves.append(Move(from: from, to: oneStep, piece: piece))
            }

            // Double move from starting position
            if from.rank == startRank,
               let twoStep = from.offset(deltaFile: 0, deltaRank: direction * 2),
               board.isEmpty(at: twoStep) {
                moves.append(Move(from: from, to: twoStep, piece: piece))
            }
        }

        // Capture
        for deltaFile in [-1, 1] {
            if let captureSquare = from.offset(deltaFile: deltaFile, deltaRank: direction) {
                // Normal capture
                if let capturedPiece = board.piece(at: captureSquare),
                   capturedPiece.color != color {
                    if captureSquare.rank == promotionRank {
                        for promoType in [PieceType.queen, .rook, .bishop, .knight] {
                            moves.append(Move(from: from, to: captureSquare, piece: piece,
                                            capturedPiece: capturedPiece, promotion: promoType))
                        }
                    } else {
                        moves.append(Move(from: from, to: captureSquare, piece: piece,
                                        capturedPiece: capturedPiece))
                    }
                }

                // En passant
                if captureSquare == position.enPassantSquare {
                    let capturedPawn = Piece(type: .pawn, color: color.opposite)
                    moves.append(Move(from: from, to: captureSquare, piece: piece,
                                    capturedPiece: capturedPawn, isEnPassant: true))
                }
            }
        }

        return moves
    }

    private func generateKnightMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        let offsets = [
            (-2, -1), (-2, 1), (-1, -2), (-1, 2),
            (1, -2), (1, 2), (2, -1), (2, 1)
        ]
        return generateJumpMoves(position: position, from: from, piece: piece, offsets: offsets)
    }

    private func generateBishopMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        return generateSlidingMoves(position: position, from: from, piece: piece, directions: directions)
    }

    private func generateRookMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        return generateSlidingMoves(position: position, from: from, piece: piece, directions: directions)
    }

    private func generateQueenMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        let directions = [
            (-1, -1), (-1, 0), (-1, 1), (0, -1),
            (0, 1), (1, -1), (1, 0), (1, 1)
        ]
        return generateSlidingMoves(position: position, from: from, piece: piece, directions: directions)
    }

    private func generateKingMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        let offsets = [
            (-1, -1), (-1, 0), (-1, 1), (0, -1),
            (0, 1), (1, -1), (1, 0), (1, 1)
        ]
        var moves = generateJumpMoves(position: position, from: from, piece: piece, offsets: offsets)

        // Castling
        moves += generateCastlingMoves(position: position, from: from, piece: piece)

        return moves
    }

    // MARK: - Helpers

    private func generateSlidingMoves(
        position: Position, from: Square, piece: Piece,
        directions: [(Int, Int)]
    ) -> [Move] {
        var moves: [Move] = []
        let board = position.board

        for (df, dr) in directions {
            var current = from
            while let next = current.offset(deltaFile: df, deltaRank: dr) {
                if let occupant = board.piece(at: next) {
                    if occupant.color != piece.color {
                        moves.append(Move(from: from, to: next, piece: piece, capturedPiece: occupant))
                    }
                    break
                }
                moves.append(Move(from: from, to: next, piece: piece))
                current = next
            }
        }

        return moves
    }

    private func generateJumpMoves(
        position: Position, from: Square, piece: Piece,
        offsets: [(Int, Int)]
    ) -> [Move] {
        var moves: [Move] = []
        let board = position.board

        for (df, dr) in offsets {
            if let to = from.offset(deltaFile: df, deltaRank: dr) {
                if let occupant = board.piece(at: to) {
                    if occupant.color != piece.color {
                        moves.append(Move(from: from, to: to, piece: piece, capturedPiece: occupant))
                    }
                } else {
                    moves.append(Move(from: from, to: to, piece: piece))
                }
            }
        }

        return moves
    }

    private func generateCastlingMoves(position: Position, from: Square, piece: Piece) -> [Move] {
        var moves: [Move] = []
        let color = piece.color
        let board = position.board
        let rank = color == .white ? 0 : 7

        // Cannot castle in check
        guard !isInCheck(position: position, color: color) else { return moves }

        // Kingside
        if position.castlingRights.kingside(for: color) {
            let f = Square(file: 5, rank: rank)
            let g = Square(file: 6, rank: rank)

            if board.isEmpty(at: f) && board.isEmpty(at: g) &&
               !isSquareAttacked(position: position, square: f, by: color.opposite) &&
               !isSquareAttacked(position: position, square: g, by: color.opposite) {
                moves.append(Move(from: from, to: g, piece: piece, castling: .kingside))
            }
        }

        // Queenside
        if position.castlingRights.queenside(for: color) {
            let d = Square(file: 3, rank: rank)
            let c = Square(file: 2, rank: rank)
            let b = Square(file: 1, rank: rank)

            if board.isEmpty(at: d) && board.isEmpty(at: c) && board.isEmpty(at: b) &&
               !isSquareAttacked(position: position, square: d, by: color.opposite) &&
               !isSquareAttacked(position: position, square: c, by: color.opposite) {
                moves.append(Move(from: from, to: c, piece: piece, castling: .queenside))
            }
        }

        return moves
    }

    /// First piece in direction from square
    private func firstPieceInDirection(
        board: Board, from: Square, deltaFile: Int, deltaRank: Int
    ) -> (square: Square, piece: Piece)? {
        var current = from
        while let next = current.offset(deltaFile: deltaFile, deltaRank: deltaRank) {
            if let piece = board.piece(at: next) {
                return (next, piece)
            }
            current = next
        }
        return nil
    }
}
