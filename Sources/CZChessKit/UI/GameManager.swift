//
//  GameManager.swift
//  CZChessKit
//
//  Created by Дмитро on 26.02.2026.
//


import Foundation
import Combine

// MARK: - GameManager

public class GameManager: ObservableObject, PlayableGame {

    // MARK: - Published

    @Published public private(set) var game: Game

    // MARK: - PlayableGame

    public var position: Position { game.position }
    public var activeColor: Color { game.activeColor }
    public var status: GameStatus { game.status }

    public var gameChanged: AnyPublisher<GameChange, Never> {
        gameChangedSubject.eraseToAnyPublisher()
    }

    // MARK: - Private

    private let gameChangedSubject = PassthroughSubject<GameChange, Never>()

    // MARK: - Init

    public init(game: Game = Game()) {
        self.game = game
    }

    public convenience init(fen: String) {
        let game = Game(fen: fen) ?? Game()
        self.init(game: game)
    }

    // MARK: - PlayableGame Methods

    public func canSelectPiece(at square: Square) -> Bool {
        game.canSelectPiece(at: square)
    }

    public func isMovePromotion(from: Square, to: Square) -> Bool {
        game.isMovePromotion(from: from, to: to)
    }

    public func destinations(from square: Square) -> [Square] {
        game.destinations(from: square)
    }

    public func canMakeMove(from: Square, to: Square, promotion: PieceType? = nil) -> Bool {
        game.canMakeMove(from: from, to: to, promotion: promotion)
    }

    @discardableResult
    public func makeMove(from: Square, to: Square, promotion: PieceType? = nil) throws -> Move {
        let move = try game.makeMove(from: from, to: to, promotion: promotion)
        gameChangedSubject.send(.moveMade(move: move, position: game.position))
        return move
    }

    // MARK: - Extended Methods (not in protocol)

    /// Make move by UCI (from server)
    @discardableResult
    public func makeMove(uci: String) throws -> Move {
        let move = try game.makeMove(uci: uci)
        gameChangedSubject.send(.moveMade(move: move, position: game.position))
        return move
    }

    /// Make move by SAN
    @discardableResult
    public func makeMove(san: String) throws -> Move {
        let move = try game.makeMove(san: san)
        gameChangedSubject.send(.moveMade(move: move, position: game.position))
        return move
    }

    /// Undo last move
    @discardableResult
    public func undoMove() -> Move? {
        let move = game.undoMove()
        gameChangedSubject.send(
            .positionSet(position: game.position, lastMove: game.currentMove)
        )
        return move
    }

    /// Resign
    public func resign(color: Color) {
        game.resign(color: color)
        gameChangedSubject.send(
            .positionSet(position: game.position, lastMove: game.currentMove)
        )
    }

    /// New game
    public func newGame(position: Position = .initial) {
        game = Game(position: position)
        gameChangedSubject.send(.positionSet(position: game.position, lastMove: nil))
    }

    /// Set position from FEN
    public func setPosition(fen: String) {
        guard let position = FEN.parse(fen) else { return }
        game = Game(position: position)
        gameChangedSubject.send(.positionSet(position: game.position, lastMove: nil))
    }

    // MARK: - Navigation

    public func goToStart() {
        game.goToStart()
        gameChangedSubject.send(.positionSet(position: game.position, lastMove: nil))
    }

    public func goToEnd() {
        game.goToEnd()
        gameChangedSubject.send(
            .positionSet(position: game.position, lastMove: game.currentMove)
        )
    }

    public func goBack() {
        game.goBack()
        gameChangedSubject.send(
            .positionSet(position: game.position, lastMove: game.currentMove)
        )
    }

    public func goForward() {
        game.goForward()
        gameChangedSubject.send(
            .positionSet(position: game.position, lastMove: game.currentMove)
        )
    }

    public func goToMove(_ index: Int) {
        game.goToMove(index)
        gameChangedSubject.send(
            .positionSet(position: game.position, lastMove: game.currentMove)
        )
    }

    // MARK: - Information

    public var moves: [Move] { game.moves }
    public var currentMoveIndex: Int { game.currentMoveIndex }
    public var currentMove: Move? { game.currentMove }
    public var isAtLatestMove: Bool { game.isAtLatestMove }
    public var fen: String { game.fen }
    public var isGameOver: Bool { game.status.isGameOver }
}
