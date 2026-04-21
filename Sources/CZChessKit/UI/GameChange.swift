//
//  GameChange.swift
//  CZChessKit
//
//  Created by Дмитро on 26.02.2026.
//


import Foundation
import Combine

// MARK: - GameChange

public enum GameChange {
    /// Move made (user, server, bot) — UI can animate
    case moveMade(move: Move, position: Position)
    /// Position changed completely (navigation, new game) — UI redraws
    case positionSet(position: Position, lastMove: Move?)
}

// MARK: - PlayableGame

/// Minimal contract for BoardViewModel.
/// BoardViewModel only knows how to show board and make move.
public protocol PlayableGame: AnyObject {
    /// Current position
    var position: Position { get }
    /// Active color
    var activeColor: Color { get }
    /// Game status
    var status: GameStatus { get }

    /// Change notifications
    var gameChanged: AnyPublisher<GameChange, Never> { get }

    /// Can select piece at square
    func canSelectPiece(at square: Square) -> Bool
    /// Is move pawn promotion
    func isMovePromotion(from: Square, to: Square) -> Bool
    /// Where piece can move
    func destinations(from square: Square) -> [Square]
    /// Can make move
    func canMakeMove(from: Square, to: Square, promotion: PieceType?) -> Bool

    /// Make move
    @discardableResult
    func makeMove(from: Square, to: Square, promotion: PieceType?) throws -> Move
}
