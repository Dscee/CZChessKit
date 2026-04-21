//
//  Piece.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//

import Foundation

public struct Piece: Equatable, Hashable, Codable, Sendable {
    public let type: PieceType
    public let color: Color

    public init(type: PieceType, color: Color) {
        self.type = type
        self.color = color
    }

    /// FEN symbol (K, Q, r, n, etc.)
    public var fenSymbol: Character {
        type.fenSymbol(for: color)
    }

    /// Create from FEN symbol
    public static func from(fen character: Character) -> Piece? {
        let color: Color = character.isUppercase ? .white : .black
        let type: PieceType? = switch character.lowercased() {
        case "k": .king
        case "q": .queen
        case "r": .rook
        case "b": .bishop
        case "n": .knight
        case "p": .pawn
        default: nil
        }
        guard let type else { return nil }
        return Piece(type: type, color: color)
    }
}

extension Piece: CustomStringConvertible {
    public var description: String {
        "\(color) \(type)"
    }
}
