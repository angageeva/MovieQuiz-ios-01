import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func correctIsLessThan(_ currentGame: GameRecord) -> Bool {
        return currentGame.correct > correct
    }
}
