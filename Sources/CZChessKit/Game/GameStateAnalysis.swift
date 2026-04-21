//
//  GameStateAnalysis.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - GameState.Analysis

extension GameState {
    
    public struct Analysis {
        public let isCheck: Bool
        public let isCheckmate: Bool
        public let isStalemate: Bool
        public let isFiftyMoveRule: Bool
        public let isThreefoldRepetition: Bool
        public let isInsufficientMaterial: Bool
        public let legalMoveCount: Int

        public var isGameOver: Bool {
            isCheckmate || isStalemate || isFiftyMoveRule ||
            isThreefoldRepetition || isInsufficientMaterial
        }

        public var isDraw: Bool {
            isStalemate || isFiftyMoveRule || isThreefoldRepetition || isInsufficientMaterial
        }
    }
}
