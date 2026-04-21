//
//  Color.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - Color

public enum Color: String, Codable, CaseIterable, Sendable {
    case white
    case black

    public var opposite: Color {
        switch self {
        case .white: return .black
        case .black: return .white
        }
    }

    public var notation: String {
        switch self {
        case .white: return "w"
        case .black: return "b"
        }
    }
}
