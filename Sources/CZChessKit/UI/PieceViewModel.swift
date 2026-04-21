//
//  PieceViewModel.swift
//  CZChessKit
//
//  Created by Дмитро on 26.02.2026.
//


import Foundation
import Combine

// MARK: - PieceViewModel

/// Represents a single square on the board with its piece
public class PieceViewModel: ObservableObject, Identifiable {
    
    // MARK: - Properties
    
    /// Unique identifier (square itself)
    public var id: Square { square }
    
    /// Square position
    public let square: Square
    
    /// Piece on this square (nil if empty)
    @Published public var piece: Piece?
    
    // MARK: - Init
    
    public init(square: Square, piece: Piece? = nil) {
        self.square = square
        self.piece = piece
    }
}
