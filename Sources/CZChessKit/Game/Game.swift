//
//  Game.swift
//  CZChessKit
//
//  Created by Дмитро on 25.02.2026.
//


import Foundation

// MARK: - Game

/// Complete chess game: position + move history + status.
public struct Game {

    /// Move history
    public private(set) var moves: [Move]

    /// Position history (for threefold repetition detection)
    public private(set) var positionHistory: [Position]

    /// Game status
    public private(set) var status: GameStatus

    /// Starting position
    public let startPosition: Position

    /// Current view index (0 = starting position, moves.count = latest)
    public private(set) var currentMoveIndex: Int

    public init(position: Position = .initial) {
        self.startPosition = position
        self.moves = []
        self.positionHistory = [position]
        self.status = .active
        self.currentMoveIndex = 0
    }

    /// Create from starting FEN
    public init?(fen: String) {
        guard let position = FEN.parse(fen) else { return nil }
        self.init(position: position)
    }

    // MARK: - Current position

    /// Position at current view index
    public var position: Position {
        positionHistory[currentMoveIndex]
    }

    /// Position at end of game (latest actual)
    public var latestPosition: Position {
        positionHistory[positionHistory.count - 1]
    }

    // MARK: - Moves

    /// Make move (only possible from end of history)
    public mutating func makeMove(_ move: Move) throws {
        guard status == .active else {
            throw GameError.gameIsOver
        }

        guard isAtLatestMove else {
            throw GameError.notAtLatestMove
        }

        guard move.piece.color == latestPosition.activeColor else {
            throw GameError.wrongColor
        }

        // Apply move
        let newPosition = latestPosition.applying(move)
        moves.append(move)
        positionHistory.append(newPosition)
        currentMoveIndex = moves.count

        // Update status
        updateStatus()
    }

    /// Make move by coordinates (from/to + optional promotion).
    /// Game itself finds complete legal Move with all flags.
    @discardableResult
    public mutating func makeMove(from: Square, to: Square, promotion: PieceType? = nil) throws -> Move {
        guard status == .active else {
            throw GameError.gameIsOver
        }

        guard isAtLatestMove else {
            throw GameError.notAtLatestMove
        }

        let validator = MoveValidator()
        guard let move = validator.findLegalMove(from: from, to: to, promotion: promotion, in: latestPosition) else {
            throw GameError.illegalMove
        }

        try makeMove(move)
        return move
    }

    /// Make move by UCI string ("e2e4", "e7e8q")
    @discardableResult
    public mutating func makeMove(uci: String) throws -> Move {
        guard let move = UCI.parse(uci, position: latestPosition) else {
            throw GameError.illegalMove
        }
        try makeMove(move)
        return move
    }

    /// Make move by SAN string ("Nf3", "O-O", "exd5#")
    @discardableResult
    public mutating func makeMove(san: String) throws -> Move {
        guard let move = SAN.parse(san, position: latestPosition) else {
            throw GameError.illegalMove
        }
        try makeMove(move)
        return move
    }

    /// Can make specific move
    public func canMakeMove(_ move: Move) -> Bool {
        guard status == .active, isAtLatestMove else { return false }
        guard move.piece.color == latestPosition.activeColor else { return false }
        let validator = MoveValidator()
        return validator.isLegal(move: move, in: latestPosition)
    }

    /// Can make move from square to square
    public func canMakeMove(from: Square, to: Square, promotion: PieceType? = nil) -> Bool {
        guard status == .active, isAtLatestMove else { return false }
        let validator = MoveValidator()
        return validator.isLegal(from: from, to: to, promotion: promotion, in: latestPosition)
    }

    // MARK: - Available moves

    /// All legal moves in current position
    public var availableMoves: [Move] {
        let generator = MoveGenerator()
        return generator.generateMoves(for: position)
    }

    /// Legal moves for piece at square
    public func movesForPiece(at square: Square) -> [Move] {
        let generator = MoveGenerator()
        return generator.generateMoves(for: position, from: square)
    }

    /// Squares where piece can move
    public func destinations(from square: Square) -> [Square] {
        movesForPiece(at: square).map(\.to)
    }

    /// Can piece at square move
    public func canPieceMove(at square: Square) -> Bool {
        !movesForPiece(at: square).isEmpty
    }

    /// Is move pawn promotion (for UI — show selection dialog)
    public func isMovePromotion(from: Square, to: Square) -> Bool {
        guard let piece = position.board.piece(at: from),
              piece.type == .pawn else { return false }
        let promotionRank = piece.color == .white ? 7 : 0
        return to.rank == promotionRank
    }

    /// Can select piece at square (has piece of active color + game not finished)
    public func canSelectPiece(at square: Square) -> Bool {
        guard status == .active, isAtLatestMove else { return false }
        guard let piece = position.board.piece(at: square) else { return false }
        return piece.color == activeColor
    }

    // MARK: - Captured pieces

    /// Captured pieces of certain color (up to current view index)
    public func capturedPieces(of color: Color) -> [Piece] {
        moves.prefix(currentMoveIndex)
            .compactMap { $0.capturedPiece }
            .filter { $0.color == color }
            .sorted { $0.type.value > $1.type.value }
    }

    /// Material advantage for color (in pawns)
    public func materialAdvantage(for color: Color) -> Int {
        let mine = materialValue(for: color)
        let opponent = materialValue(for: color.opposite)
        return mine - opponent
    }

    private func materialValue(for color: Color) -> Int {
        let captured = capturedPieces(of: color)
        let lost = captured.reduce(0) { $0 + $1.type.value }
        let total = startingMaterialValue
        return total - lost
    }

    private var startingMaterialValue: Int {
        // Q(9) + 2R(10) + 2B(6) + 2N(6) + 8P(8) = 39
        39
    }


    /// Undo last move (removes from history)
    public mutating func undoMove() -> Move? {
        guard let lastMove = moves.popLast() else { return nil }
        positionHistory.removeLast()

        // Adjust index if needed
        if currentMoveIndex > moves.count {
            currentMoveIndex = moves.count
        }

        status = .active
        return lastMove
    }

    /// Resign
    public mutating func resign(color: Color) {
        guard status == .active else { return }
        status = .gameOver(result: .win(color.opposite, reason: .resignation))
    }

    /// Timeout - player ran out of time
    public mutating func timeout(color: Color) {
        guard status == .active else { return }
        status = .gameOver(result: .win(color.opposite, reason: .timeout))
    }

    /// Draw by agreement
    public mutating func drawByAgreement() {
        guard status == .active else { return }
        status = .gameOver(result: .draw(.agreement))
    }

    // MARK: - History navigation

    /// Go to specific move (0 = to start, moves.count = end)
    public mutating func goToMove(_ index: Int) {
        let clamped = max(0, min(index, moves.count))
        currentMoveIndex = clamped
    }

    /// To start
    public mutating func goToStart() {
        currentMoveIndex = 0
    }

    /// To end
    public mutating func goToEnd() {
        currentMoveIndex = moves.count
    }

    /// One move back
    @discardableResult
    public mutating func goBack() -> Bool {
        guard currentMoveIndex > 0 else { return false }
        currentMoveIndex -= 1
        return true
    }

    /// One move forward
    @discardableResult
    public mutating func goForward() -> Bool {
        guard currentMoveIndex < moves.count else { return false }
        currentMoveIndex += 1
        return true
    }

    /// Are we at latest move
    public var isAtLatestMove: Bool {
        currentMoveIndex == moves.count
    }

    /// Are we at start
    public var isAtStart: Bool {
        currentMoveIndex == 0
    }

    /// Move at current index (nil if at start)
    public var currentMove: Move? {
        guard currentMoveIndex > 0 else { return nil }
        return moves[currentMoveIndex - 1]
    }

    // MARK: - Information

    /// Active color (at current view position)
    public var activeColor: Color {
        position.activeColor
    }

    /// Current move number
    public var currentMoveNumber: Int {
        position.fullmoveNumber
    }

    /// Number of moves made
    public var moveCount: Int {
        moves.count
    }

    /// Current FEN
    public var fen: String {
        FEN.generate(from: position)
    }

    // MARK: - Private

    private mutating func updateStatus() {
        let generator = MoveGenerator()
        let pos = latestPosition
        let legalMoves = generator.generateMoves(for: pos)

        if legalMoves.isEmpty {
            // No legal moves
            if generator.isInCheck(position: pos, color: pos.activeColor) {
                // Checkmate — winner is who made previous move
                status = .gameOver(result: .win(pos.activeColor.opposite, reason: .checkmate))
            } else {
                // Stalemate
                status = .gameOver(result: .draw(.stalemate))
            }
            return
        }

        // 50-move rule
        if pos.halfmoveClock >= 100 {
            status = .gameOver(result: .draw(.fiftyMoveRule))
            return
        }

        // Threefold repetition
        if isThreefoldRepetition() {
            status = .gameOver(result: .draw(.threefoldRepetition))
            return
        }

        // Insufficient material
        if isInsufficientMaterial() {
            status = .gameOver(result: .draw(.insufficientMaterial))
            return
        }

        status = .active
    }

    private func isThreefoldRepetition() -> Bool {
        let current = latestPosition
        var count = 0
        for pos in positionHistory {
            if pos.board == current.board &&
               pos.activeColor == current.activeColor &&
               pos.castlingRights == current.castlingRights &&
               pos.enPassantSquare == current.enPassantSquare {
                count += 1
            }
            if count >= 3 { return true }
        }
        return false
    }

    private func isInsufficientMaterial() -> Bool {
        let whitePieces = latestPosition.board.squares(for: .white)
        let blackPieces = latestPosition.board.squares(for: .black)

        let whiteTypes = Set(whitePieces.map { $0.piece.type })
        let blackTypes = Set(blackPieces.map { $0.piece.type })

        // King vs king
        if whitePieces.count == 1 && blackPieces.count == 1 {
            return true
        }

        // King + bishop/knight vs king
        if whitePieces.count == 1 && blackPieces.count == 2 {
            if blackTypes.isSubset(of: [.king, .bishop]) || blackTypes.isSubset(of: [.king, .knight]) {
                return true
            }
        }
        if blackPieces.count == 1 && whitePieces.count == 2 {
            if whiteTypes.isSubset(of: [.king, .bishop]) || whiteTypes.isSubset(of: [.king, .knight]) {
                return true
            }
        }

        // King + bishop vs king + bishop (same-colored bishops)
        if whitePieces.count == 2 && blackPieces.count == 2 &&
           whiteTypes == [.king, .bishop] && blackTypes == [.king, .bishop] {
            let whiteBishopSquare = whitePieces.first { $0.piece.type == .bishop }!.square
            let blackBishopSquare = blackPieces.first { $0.piece.type == .bishop }!.square
            if whiteBishopSquare.color == blackBishopSquare.color {
                return true
            }
        }

        return false
    }
}
