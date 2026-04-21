//
//  BoardHighlights.swift
//  CZChessKit
//
//  Created by Дмитро on 26.02.2026.
//


import Foundation
import Combine

// MARK: - BoardHighlights

/// Manages visual highlights on the board (separate from piece positions)
public class BoardHighlights: ObservableObject {
    
    // MARK: - Published State
    
    /// Legal move indicators (dots/circles)
    @Published public var legalMoves: Set<Square> = []
    
    /// Last move highlighting (from/to squares)
    @Published public var lastMoveSquares: Set<Square> = []
    
    /// King in check square
    @Published public var checkSquare: Square?
    
    /// User custom highlights
    @Published public var customHighlights: Set<Square> = []
    
    // MARK: - Methods
    
    /// Set last move
    public func setLastMove(_ move: Move?) {
        if let move = move {
            lastMoveSquares = [move.from, move.to]
        } else {
            lastMoveSquares = []
        }
    }
    
    /// Show legal moves for selected piece
    public func showLegalMoves(_ squares: [Square]) {
        legalMoves = Set(squares)
    }
    
    /// Clear all highlights
    public func clear() {
        legalMoves = []
        customHighlights = []
    }
    
    /// Clear everything including last move
    public func clearAll() {
        legalMoves = []
        lastMoveSquares = []
        checkSquare = nil
        customHighlights = []
    }
}
