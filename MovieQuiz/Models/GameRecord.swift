import Foundation

// Структура записи игрового рекорда
struct GameRecord: Codable {
    // количество правильных ответов рекордной попытки
    let correct: Int
    // общее количество вопросов-ответов
    let total: Int
    // дата и время рекордной попытки
    let date: Date

    func correctIsLessThan(_ currentGame: GameRecord) -> Bool {
        return currentGame.correct > correct
    }
}
