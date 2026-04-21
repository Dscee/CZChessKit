//
//  CastlingRights.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - CastlingRights

public struct CastlingRights: Equatable, Hashable, Codable, Sendable {
    public var whiteKingside: Bool
    public var whiteQueenside: Bool
    public var blackKingside: Bool
    public var blackQueenside: Bool

    public init(
        whiteKingside: Bool = true,
        whiteQueenside: Bool = true,
        blackKingside: Bool = true,
        blackQueenside: Bool = true
    ) {
        self.whiteKingside = whiteKingside
        self.whiteQueenside = whiteQueenside
        self.blackKingside = blackKingside
        self.blackQueenside = blackQueenside
    }

    /// Initial position — all castling available
    public static let initial = CastlingRights()

    /// No castling
    public static let none = CastlingRights(
        whiteKingside: false,
        whiteQueenside: false,
        blackKingside: false,
        blackQueenside: false
    )

    /// Is there at least one castling for color
    public func hasAny(for color: Color) -> Bool {
        switch color {
        case .white: return whiteKingside || whiteQueenside
        case .black: return blackKingside || blackQueenside
        }
    }

    /// Kingside castling for color
    public func kingside(for color: Color) -> Bool {
        switch color {
        case .white: return whiteKingside
        case .black: return blackKingside
        }
    }

    /// Queenside castling for color
    public func queenside(for color: Color) -> Bool {
        switch color {
        case .white: return whiteQueenside
        case .black: return blackQueenside
        }
    }

    /// Remove all rights for color
    public mutating func removeAll(for color: Color) {
        switch color {
        case .white:
            whiteKingside = false
            whiteQueenside = false
        case .black:
            blackKingside = false
            blackQueenside = false
        }
    }

    /// FEN string (KQkq, Kq, -, etc.)
    public var fen: String {
        var result = ""
        if whiteKingside  { result += "K" }
        if whiteQueenside { result += "Q" }
        if blackKingside  { result += "k" }
        if blackQueenside { result += "q" }
        return result.isEmpty ? "-" : result
    }

    /// Parse from FEN
    public init?(fen: String) {
        if fen == "-" {
            self = .none
            return
        }
        self.whiteKingside  = fen.contains("K")
        self.whiteQueenside = fen.contains("Q")
        self.blackKingside  = fen.contains("k")
        self.blackQueenside = fen.contains("q")
    }
}
