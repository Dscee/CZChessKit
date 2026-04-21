//
//  PGNTags.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - PGN.Tags

extension PGN {
    
    public struct Tags {
        public var event: String?
        public var site: String?
        public var date: String?
        public var round: String?
        public var white: String?
        public var black: String?
        public var result: String?
        public var fen: String?
        public var additional: [String: String] = [:]

        public init() {}
    }
}
