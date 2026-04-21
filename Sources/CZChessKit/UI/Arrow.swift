//
//  Arrow.swift
//  CZChessKit
//
//  Created by Дмитро on 26.02.2026.
//


import Foundation

// MARK: - Arrow

public struct Arrow: Equatable, Identifiable {
    public let id = UUID()
    public let from: Square
    public let to: Square
    public let color: ArrowColor

    public init(from: Square, to: Square, color: ArrowColor = .default) {
        self.from = from
        self.to = to
        self.color = color
    }

    public enum ArrowColor: Equatable {
        case `default`
        case best
        case good
        case mistake
        case custom(red: Double, green: Double, blue: Double, alpha: Double)
    }
}
