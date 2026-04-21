//
//  BoardViewModel.swift
//  CZChessKit
//
//  Created by Дмитро on 26.02.2026.
//


import Foundation
import Combine

// MARK: - BoardViewModel

open class BoardViewModel: ObservableObject {

    // MARK: - Published State

    /// All 64 squares with their pieces
    @Published public private(set) var pieces: [PieceViewModel] = []

    /// Visual highlights (legal moves, last move, check, custom)
    @Published public private(set) var highlights = BoardHighlights()

    /// Current FEN for display (convenience)
    @Published public private(set) var fen: String = ""

    /// Board flipped
    @Published public var isFlipped: Bool

    /// Is user interaction enabled
    @Published public var isUserInteractionEnabled: Bool = true

    // MARK: - Subjects

    /// Snap piece back to place (invalid drag)
    public let snapBackPiece = PassthroughSubject<Square, Never>()

    /// Show promotion dialog
    public let showPromotion = PassthroughSubject<Color, Never>()
    
    /// Move animation (from, to) - triggered on .moveMade
    public let animateMove = PassthroughSubject<Move, Never>()

    // MARK: - Private

    private let game: PlayableGame
    private var selectedSquare: Square?
    private var pendingPromotionMove: (from: Square, to: Square)?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(game: PlayableGame, isFlipped: Bool = false) {
        self.game = game
        self.isFlipped = isFlipped
        initializePieces()
        subscribe()
        syncFromGame(position: game.position, lastMove: nil)
    }
    
    // MARK: - Piece Access
    
    /// Get piece view model at square
    public func pieceViewModel(at square: Square) -> PieceViewModel? {
        pieces.first { $0.square == square }
    }

    // MARK: - Piece Selection

    /// User tapped on square
    public func selectPiece(at square: Square) {
        guard isUserInteractionEnabled else { return }
        guard pendingPromotionMove == nil else { return }

        guard canSelectPiece(at: square) else {
            hideMoveIndicators()
            return
        }

        guard let selected = selectedSquare else {
            showMoveIndicators(at: square)
            return
        }

        if selected == square {
            hideMoveIndicators()
            return
        }

        if !highlights.legalMoves.contains(square) {
            hideMoveIndicators()
            selectPiece(at: square)
            return
        }

        attemptMove(from: selected, to: square)
    }

    /// Can select/tap square
    public func canSelectPiece(at square: Square) -> Bool {
        game.canSelectPiece(at: square) || highlights.legalMoves.contains(square)
    }

    // MARK: - Promotion
    /// User selected promoted piece
    public func selectPromotedPiece(_ pieceType: PieceType) {
        guard let pending = pendingPromotionMove else { return }

        do {
            try game.makeMove(from: pending.from, to: pending.to, promotion: pieceType)
        } catch {
            // makeMove failed
        }

        pendingPromotionMove = nil
        hideMoveIndicators()
    }

    /// Cancel promotion
    public func cancelPromotion() {
        pendingPromotionMove = nil
        hideMoveIndicators()
    }

    // MARK: - Drag & Drop

    /// User dragged piece
    public func draggedPiece(from: Square, to: Square) {
        guard isUserInteractionEnabled else {
            snapBackPiece.send(from)
            return
        }

        if game.isMovePromotion(from: from, to: to) {
            snapBackPiece.send(from)
            pendingPromotionMove = (from: from, to: to)
            showPromotion.send(game.activeColor)
            return
        }

        if game.canMakeMove(from: from, to: to, promotion: nil) {
            do {
                try game.makeMove(from: from, to: to, promotion: nil)
                hideMoveIndicators()
            } catch {
                snapBackPiece.send(from)
            }
        } else {
            snapBackPiece.send(from)
        }
    }

    /// User started dragging piece
    public func draggingPiece(at square: Square) {
        hideMoveIndicators()
    }

    // MARK: - Clear

    /// Clear visual elements
    public func clear() {
        highlights.clear()
        selectedSquare = nil
    }
    
    /// Highlight squares (for user interaction)
    public func highlightSquares(_ squares: Set<Square>) {
        highlights.customHighlights = squares
    }

    // MARK: - Private

    private func attemptMove(from: Square, to: Square) {
        if game.isMovePromotion(from: from, to: to) {
            hideMoveIndicators()
            pendingPromotionMove = (from: from, to: to)
            showPromotion.send(game.activeColor)
            return
        }

        do {
            try game.makeMove(from: from, to: to, promotion: nil)
            hideMoveIndicators()
        } catch {
            hideMoveIndicators()
        }
    }

    private func showMoveIndicators(at square: Square) {
        highlights.showLegalMoves(game.destinations(from: square))
        selectedSquare = square
    }

    private func hideMoveIndicators() {
        highlights.legalMoves = []
        selectedSquare = nil
    }
    
    private func initializePieces() {
        // Create 64 PieceViewModels for all squares
        pieces = Square.all.map { square in
            PieceViewModel(square: square)
        }
    }

    private func subscribe() {
        game.gameChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                guard let self else { return }

                self.clear()

                switch change {
                case .moveMade(let move, let position):
                    // Animate the move
                    self.animateMove.send(move)
                    self.syncFromGame(position: position, lastMove: move, animated: true)
                case .positionSet(let position, let lastMove):
                    // Instant update (no animation)
                    self.syncFromGame(position: position, lastMove: lastMove, animated: false)
                }
            }
            .store(in: &cancellables)
    }

    private func syncFromGame(position: Position, lastMove: Move?, animated: Bool = false) {
        fen = FEN.generate(from: position)

        // Update all pieces from position
        for pieceVM in pieces {
            pieceVM.piece = position.board.piece(at: pieceVM.square)
        }
        
        // Update highlights
        highlights.setLastMove(lastMove)
    }
}
