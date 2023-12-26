import Foundation

// создание структуры вопроса
struct QuizQuestion {
    // данные картинки-постера к фильму
    let image: Data
    // строка с вопросом о рейтинге фильма
    let text: String
    // правильный ответ
    let correctAnswer: Bool
}
