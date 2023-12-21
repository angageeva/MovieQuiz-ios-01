import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            correctAnswer: false)
        ]

    //добавления свойства с делегатом
    weak var delegate: QuestionFactoryDelegate?
    // Массив индексов непоказанных вопросов
    var unshownIndexes: [Int] = []

    // Функция заполнения массива неиспользуемых индексов
    func refillUnshownIndexes() {
        self.unshownIndexes = Array(0..<questions.count)
    }

    func requestNextQuestion() {
        guard let index = unshownIndexes.randomElement() else {
            delegate?.didRecieveNextQuestion(question: nil)
            return
        }
        let question = questions[safe: index]

        self.unshownIndexes = unshownIndexes.filter { $0 != index }
        delegate?.didRecieveNextQuestion(question: question)
    }
}
