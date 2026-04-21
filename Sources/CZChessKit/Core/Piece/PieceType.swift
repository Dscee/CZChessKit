//
//  PieceType.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//

import Foundation

public enum PieceType: String, Codable, CaseIterable, Sendable  {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn

    public var notation: String {
        switch self {
        case .king:   return "K"
        case .queen:  return "Q"
        case .rook:   return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn:   return ""
        }
    }

    /// FEN symbol (uppercase for white, lowercase for black)
    public func fenSymbol(for color: Color) -> Character {
        let symbol: Character = switch self {
        case .king:   "k"
        case .queen:  "q"
        case .rook:   "r"
        case .bishop: "b"
        case .knight: "n"
        case .pawn:   "p"
        }
        return color == .white ? Character(symbol.uppercased()) : symbol
    }

    /// Material value of the piece
    public var value: Int {
        switch self {
        case .king:   return 0
        case .queen:  return 9
        case .rook:   return 5
        case .bishop: return 3
        case .knight: return 3
        case .pawn:   return 1
        }
    }
}
