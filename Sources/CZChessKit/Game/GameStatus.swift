import Foundation

// MARK: - GameStatus

public enum GameStatus: Equatable, Codable {
    case active
    case gameOver(result: GameResult)

    public var isGameOver: Bool {
        if case .gameOver = self {
            return true
        }
        return false
    }

    public var isDraw: Bool {
        if case .gameOver(result: .draw) = self {
            return true
        }
        return false
    }

    public var winner: Color? {
        if case .gameOver(result: .win(let color, _)) = self {
            return color
        }
        return nil
    }
}

// MARK: - GameResult

public enum GameResult: Equatable, Codable {
    case win(Color, reason: WinReason)
    case draw(DrawReason)
}

// MARK: - WinReason

public enum WinReason: Equatable, Codable {
    case checkmate
    case resignation
    case timeout
}

// MARK: - DrawReason

public enum DrawReason: Equatable, Codable {
    case stalemate
    case fiftyMoveRule
    case threefoldRepetition
    case insufficientMaterial
    case agreement
}
