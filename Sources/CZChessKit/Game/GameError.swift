import Foundation

// MARK: - GameError

public enum GameError: Error, LocalizedError {
    case gameIsOver
    case wrongColor
    case illegalMove
    case invalidFEN
    case notAtLatestMove

    public var errorDescription: String? {
        switch self {
        case .gameIsOver: return "Game is already over"
        case .wrongColor: return "It's not your turn now"
        case .illegalMove: return "Illegal move"
        case .invalidFEN: return "Invalid FEN string"
        case .notAtLatestMove: return "First go to the latest move"
        }
    }
}
