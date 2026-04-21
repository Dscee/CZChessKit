import Testing
@testable import CZChessKit

@Test func example() async throws {
    var game = Game(fen: FEN.startingPosition)!
    
    do {
//        let move = Move(uci: "e4")!
        let resultMove = try game.makeMove(uci: "e2e4")
        
        
        
        
                
        print("MOVE IS -\(resultMove)")
        
    } catch {
        print(error)
    }

}

@Test func example2() async throws {
    var game = Game(fen: FEN.startingPosition)!
    
    do {
//        let move = Move(uci: "e4")!
        try game.makeMove(from: .e2, to: .e4)
        try game.makeMove(from: .a7, to: .a6)
        try game.makeMove(from: .e4, to: .e5)
        try game.makeMove(from: .d7, to: .d5)
        
        let m = game.movesForPiece(at: .init("e5")!)
        
                        
        print("MOVE IS -\(m)")
        
    } catch {
        print(error)
    }

}

@Test func example3() async throws {
    var game = Game(fen: FEN.startingPosition)!
    
    do {
//        let move = Move(uci: "e4")!
        try game.makeMove(from: .g1, to: .f3)
        try game.makeMove(from: .g8, to: .f6)
        try game.makeMove(from: .f3, to: .g1)
        try game.makeMove(from: .f6, to: .g8)
        
        game.goToMove(2)
        
        print(game.currentMove)
        
        
//        try game.makeMove(from: .g1, to: .f3)
//        try game.makeMove(from: .g8, to: .f6)
//        try game.makeMove(from: .f3, to: .g1)
//        try game.makeMove(from: .f6, to: .g8)
//        
//        
//        
//        try game.makeMove(from: .g1, to: .f3)
//        try game.makeMove(from: .g8, to: .f6)
//        try game.makeMove(from: .f3, to: .g1)
//        try game.makeMove(from: .f6, to: .g8)
//        
//        try game.makeMove(from: .g1, to: .f3)
//        try game.makeMove(from: .g8, to: .f6)
//        try game.makeMove(from: .f3, to: .g1)
//        try game.makeMove(from: .f6, to: .g8)
//                        
//        
//        try game.makeMove(from: .g1, to: .f3)
//        try game.makeMove(from: .g8, to: .f6)
//        try game.makeMove(from: .f3, to: .g1)
//        try game.makeMove(from: .f6, to: .g8)
//        print("MOVE IS -\(m)")
        
    } catch {
        print(error)
    }

}
