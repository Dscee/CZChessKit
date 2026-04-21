//
//  Square.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - Square

public struct Square: Equatable, Hashable, Codable, Sendable {
    /// File (0 = a, 7 = h)
    public let file: Int
    /// Rank (0 = 1, 7 = 8)
    public let rank: Int

    public init(file: Int, rank: Int) {
//        precondition(file >= 0 && file < 8, "File must be 0-7")
//        precondition(rank >= 0 && rank < 8, "Rank must be 0-7")
        self.file = file
        self.rank = rank
    }

    /// Create from notation ("e4")
    public init?(_ notation: String) {
        guard notation.count == 2 else { return nil }
        let chars = Array(notation.lowercased())

        guard let file = chars[0].asciiValue.map({ Int($0) - Int(Character("a").asciiValue!) }),
              let rank = Int(String(chars[1])).map({ $0 - 1 }),
              file >= 0, file < 8, rank >= 0, rank < 8 else {
            return nil
        }
        self.file = file
        self.rank = rank
    }

    /// Square notation ("a1", "e4", "h8")
    public var notation: String {
        let fileLetter = Character(UnicodeScalar(Int(Character("a").asciiValue!) + file)!)
        return "\(fileLetter)\(rank + 1)"
    }

    /// Square color
    public var color: Color {
        (file + rank) % 2 == 0 ? .black : .white
    }

    /// Offset by (deltaFile, deltaRank), returns nil if outside the board
    public func offset(deltaFile: Int, deltaRank: Int) -> Square? {
        let newFile = file + deltaFile
        let newRank = rank + deltaRank
        guard newFile >= 0, newFile < 8, newRank >= 0, newRank < 8 else {
            return nil
        }
        return Square(file: newFile, rank: newRank)
    }

    // MARK: - Standard squares

    public static let a1 = Square(file: 0, rank: 0)
    public static let b1 = Square(file: 1, rank: 0)
    public static let c1 = Square(file: 2, rank: 0)
    public static let d1 = Square(file: 3, rank: 0)
    public static let e1 = Square(file: 4, rank: 0)
    public static let f1 = Square(file: 5, rank: 0)
    public static let g1 = Square(file: 6, rank: 0)
    public static let h1 = Square(file: 7, rank: 0)

    public static let a2 = Square(file: 0, rank: 1)
    public static let b2 = Square(file: 1, rank: 1)
    public static let c2 = Square(file: 2, rank: 1)
    public static let d2 = Square(file: 3, rank: 1)
    public static let e2 = Square(file: 4, rank: 1)
    public static let f2 = Square(file: 5, rank: 1)
    public static let g2 = Square(file: 6, rank: 1)
    public static let h2 = Square(file: 7, rank: 1)

    public static let a3 = Square(file: 0, rank: 2)
    public static let b3 = Square(file: 1, rank: 2)
    public static let c3 = Square(file: 2, rank: 2)
    public static let d3 = Square(file: 3, rank: 2)
    public static let e3 = Square(file: 4, rank: 2)
    public static let f3 = Square(file: 5, rank: 2)
    public static let g3 = Square(file: 6, rank: 2)
    public static let h3 = Square(file: 7, rank: 2)

    public static let a4 = Square(file: 0, rank: 3)
    public static let b4 = Square(file: 1, rank: 3)
    public static let c4 = Square(file: 2, rank: 3)
    public static let d4 = Square(file: 3, rank: 3)
    public static let e4 = Square(file: 4, rank: 3)
    public static let f4 = Square(file: 5, rank: 3)
    public static let g4 = Square(file: 6, rank: 3)
    public static let h4 = Square(file: 7, rank: 3)

    public static let a5 = Square(file: 0, rank: 4)
    public static let b5 = Square(file: 1, rank: 4)
    public static let c5 = Square(file: 2, rank: 4)
    public static let d5 = Square(file: 3, rank: 4)
    public static let e5 = Square(file: 4, rank: 4)
    public static let f5 = Square(file: 5, rank: 4)
    public static let g5 = Square(file: 6, rank: 4)
    public static let h5 = Square(file: 7, rank: 4)

    public static let a6 = Square(file: 0, rank: 5)
    public static let b6 = Square(file: 1, rank: 5)
    public static let c6 = Square(file: 2, rank: 5)
    public static let d6 = Square(file: 3, rank: 5)
    public static let e6 = Square(file: 4, rank: 5)
    public static let f6 = Square(file: 5, rank: 5)
    public static let g6 = Square(file: 6, rank: 5)
    public static let h6 = Square(file: 7, rank: 5)

    public static let a7 = Square(file: 0, rank: 6)
    public static let b7 = Square(file: 1, rank: 6)
    public static let c7 = Square(file: 2, rank: 6)
    public static let d7 = Square(file: 3, rank: 6)
    public static let e7 = Square(file: 4, rank: 6)
    public static let f7 = Square(file: 5, rank: 6)
    public static let g7 = Square(file: 6, rank: 6)
    public static let h7 = Square(file: 7, rank: 6)

    public static let a8 = Square(file: 0, rank: 7)
    public static let b8 = Square(file: 1, rank: 7)
    public static let c8 = Square(file: 2, rank: 7)
    public static let d8 = Square(file: 3, rank: 7)
    public static let e8 = Square(file: 4, rank: 7)
    public static let f8 = Square(file: 5, rank: 7)
    public static let g8 = Square(file: 6, rank: 7)
    public static let h8 = Square(file: 7, rank: 7)

    /// All 64 squares
    public static let all: [Square] = {
        var squares: [Square] = []
        for rank in 0..<8 {
            for file in 0..<8 {
                squares.append(Square(file: file, rank: rank))
            }
        }
        return squares
    }()
}

extension Square: CustomStringConvertible {
    public var description: String { notation }
}

extension Square: Comparable {
    public static func < (lhs: Square, rhs: Square) -> Bool {
        if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
        return lhs.file < rhs.file
    }
}
