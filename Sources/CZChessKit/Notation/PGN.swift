//
//  PGN.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - PGN

/// Portable Game Notation — complete game record.
public enum PGN {

    // MARK: - Generate

    /// Generate PGN string from Game
    public static func generate(from game: Game, tags: Tags = Tags()) -> String {
        var result = ""

        // Tags
        result += tag("Event", tags.event ?? "?")
        result += tag("Site", tags.site ?? "?")
        result += tag("Date", tags.date ?? "????.??.??")
        result += tag("Round", tags.round ?? "?")
        result += tag("White", tags.white ?? "?")
        result += tag("Black", tags.black ?? "?")
        result += tag("Result", tags.result ?? resultString(game.status))

        if game.startPosition != .initial {
            result += tag("SetUp", "1")
            result += tag("FEN", FEN.generate(from: game.startPosition))
        }

        for (key, value) in tags.additional {
            result += tag(key, value)
        }

        result += "\n"

        // Moves
        var position = game.startPosition
        var moveText = ""
        var moveNumber = position.fullmoveNumber

        for (index, move) in game.moves.enumerated() {
            let isWhite = position.activeColor == .white

            if isWhite {
                moveText += "\(moveNumber). "
            } else if index == 0 {
                // If game starts with black's move
                moveText += "\(moveNumber)... "
            }

            let san = SAN.generate(move: move, position: position)
            moveText += san + " "

            if !isWhite {
                moveNumber += 1
            }

            position = position.applying(move)
        }

        moveText += resultString(game.status)

        // Wrap to 80 characters per line
        result += wrapText(moveText.trimmingCharacters(in: .whitespaces), lineLength: 80)

        return result
    }

    // MARK: - Parse

    /// Parse PGN string to Game and tags
    public static func parse(_ pgn: String) -> (game: Game, tags: Tags)? {
        var tags = Tags()
        var moveSection = ""
        var inMoves = false

        let lines = pgn.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                // Parse tag
                let content = String(trimmed.dropFirst().dropLast())
                if let (key, value) = parseTag(content) {
                    switch key.lowercased() {
                    case "event": tags.event = value
                    case "site": tags.site = value
                    case "date": tags.date = value
                    case "round": tags.round = value
                    case "white": tags.white = value
                    case "black": tags.black = value
                    case "result": tags.result = value
                    case "fen": tags.fen = value
                    default: tags.additional[key] = value
                    }
                }
            } else if !trimmed.isEmpty {
                inMoves = true
                moveSection += " " + trimmed
            }
        }

        // Determine starting position
        let startPosition: Position
        if let fen = tags.fen, let pos = FEN.parse(fen) {
            startPosition = pos
        } else {
            startPosition = .initial
        }

        var game = Game(position: startPosition)

        // Parse moves
        let moveTokens = tokenizeMoves(moveSection)

        for token in moveTokens {
            // Skip move numbers and result
            if token.contains(".") || token == "1-0" || token == "0-1" ||
               token == "1/2-1/2" || token == "*" {
                continue
            }

            if let move = SAN.parse(token, position: game.position) {
                try? game.makeMove(move)
            }
        }

        return (game, tags)
    }

    // MARK: - Private

    private static func tag(_ key: String, _ value: String) -> String {
        "[\(key) \"\(value)\"]\n"
    }

    private static func parseTag(_ content: String) -> (String, String)? {
        guard let spaceIndex = content.firstIndex(of: " ") else { return nil }
        let key = String(content[content.startIndex..<spaceIndex])
        var value = String(content[content.index(after: spaceIndex)...])
        value = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        return (key, value)
    }

    private static func resultString(_ status: GameStatus) -> String {
        switch status {
        case .gameOver(result: .win(let winner, _)):
            return winner == .white ? "1-0" : "0-1"
        case .gameOver(result: .draw):
            return "1/2-1/2"
        case .active:
            return "*"
        }
    }

    private static func tokenizeMoves(_ text: String) -> [String] {
        // Remove comments
        var cleaned = text
        // Remove {comments}
        while let start = cleaned.range(of: "{"),
              let end = cleaned.range(of: "}", range: start.upperBound..<cleaned.endIndex) {
            cleaned.removeSubrange(start.lowerBound...end.lowerBound)
        }
        // Remove (variations)
        while let start = cleaned.range(of: "("),
              let end = cleaned.range(of: ")", range: start.upperBound..<cleaned.endIndex) {
            cleaned.removeSubrange(start.lowerBound...end.lowerBound)
        }

        return cleaned
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
    }

    private static func wrapText(_ text: String, lineLength: Int) -> String {
        var result = ""
        var currentLine = ""

        for word in text.split(separator: " ") {
            if currentLine.count + word.count + 1 > lineLength {
                result += currentLine + "\n"
                currentLine = String(word)
            } else {
                if !currentLine.isEmpty { currentLine += " " }
                currentLine += word
            }
        }

        if !currentLine.isEmpty {
            result += currentLine
        }

        return result
    }
}
