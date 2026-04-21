//
//  GameState.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - GameState

/// Game state analysis — check, checkmate, stalemate, draw.
public struct GameState {

    private let generator = MoveGenerator()

    public init() {}

    /// Full position analysis
    public func analyze(position: Position, positionHistory: [Position] = []) -> Analysis {
        let color = position.activeColor
        let inCheck = generator.isInCheck(position: position, color: color)
        let legalMoves = generator.generateMoves(for: position)
        let hasMoves = !legalMoves.isEmpty

        let isCheckmate = inCheck && !hasMoves
        let isStalemate = !inCheck && !hasMoves

        let isFiftyMoveRule = position.halfmoveClock >= 100
        let isRepetition = checkThreefoldRepetition(current: position, history: positionHistory)
        let isInsufficient = checkInsufficientMaterial(board: position.board)

        return Analysis(
            isCheck: inCheck,
            isCheckmate: isCheckmate,
            isStalemate: isStalemate,
            isFiftyMoveRule: isFiftyMoveRule,
            isThreefoldRepetition: isRepetition,
            isInsufficientMaterial: isInsufficient,
            legalMoveCount: legalMoves.count
        )
    }

    // MARK: - Private

    private func checkThreefoldRepetition(current: Position, history: [Position]) -> Bool {
        var count = 0
        for pos in history {
            if pos.board == current.board &&
               pos.activeColor == current.activeColor &&
               pos.castlingRights == current.castlingRights &&
               pos.enPassantSquare == current.enPassantSquare {
                count += 1
            }
            if count >= 3 { return true }
        }
        return false
    }

    private func checkInsufficientMaterial(board: Board) -> Bool {
        let white = board.squares(for: .white)
        let black = board.squares(for: .black)

        // K vs K
        if white.count == 1 && black.count == 1 { return true }

        // K+minor vs K
        if white.count == 1 && black.count == 2 {
            let types = Set(black.map { $0.piece.type })
            if types.isSubset(of: [.king, .bishop]) || types.isSubset(of: [.king, .knight]) {
                return true
            }
        }
        if black.count == 1 && white.count == 2 {
            let types = Set(white.map { $0.piece.type })
            if types.isSubset(of: [.king, .bishop]) || types.isSubset(of: [.king, .knight]) {
                return true
            }
        }

        // K+B vs K+B (same color bishops)
        if white.count == 2 && black.count == 2 {
            let whiteTypes = Set(white.map { $0.piece.type })
            let blackTypes = Set(black.map { $0.piece.type })
            if whiteTypes == [.king, .bishop] && blackTypes == [.king, .bishop] {
                let wb = white.first { $0.piece.type == .bishop }!.square
                let bb = black.first { $0.piece.type == .bishop }!.square
                if wb.color == bb.color { return true }
            }
        }

        return false
    }
}
