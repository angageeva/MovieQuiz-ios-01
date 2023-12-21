import Foundation

final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.correctIsLessThan(currentGame) {
            bestGame = currentGame
        }
        gamesCount += 1
        totalCorrectAnswers += count
        totalQuestionsAmount += amount
    }
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case totalCorrectAnswers, totalQuestionsAmount, bestGame, gamesCount
    }
    
    var totalCorrectAnswers: Int {
        get {
            userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalQuestionsAmount: Int {
        get {
            userDefaults.integer(forKey: Keys.totalQuestionsAmount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalQuestionsAmount.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            (Double(totalCorrectAnswers)/Double(totalQuestionsAmount)) * 100
        }
    }
    
    var gamesCount: Int {
        get{
            guard let data = userDefaults.data(forKey: "gamesCount"),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: "gamesCount")
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}

