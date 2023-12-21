import Foundation

// создание структуры вопроса
struct QuizQuestion {
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String = "Рейтинг этого фильма больше чем 6?"
    // правильный ответ
    let correctAnswer: Bool
}
