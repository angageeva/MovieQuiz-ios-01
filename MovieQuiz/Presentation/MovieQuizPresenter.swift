import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    //общее количество вопросов для квиза
    let questionsAmount = 10
    // создание переменной с индексом текущего вопроса, начальное значение 0
    var currentQuestionIndex = 0
    
    //вопрос, который видит пользователь
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    //фабрика вопросов
    lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    
    // переменной со счётчиком правильных ответов, начальное значение 0
    var correctAnswers = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.refillUnshownIndexes()
        questionFactory.requestNextQuestion()
    }
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber)

        return questionStep
    }
    
    // создание функции для кнопок «Да» и «Нет»
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        let currentQuestionViewModel = convert(model: question)

        self.currentQuestion = question

        DispatchQueue.main.async{ [weak self] in
            self?.viewController?.show(quiz: currentQuestionViewModel)
        }
    }
    
    // метод, который содержит логику перехода в один из сценариев
    func showNextQuestionOrResult() {
        if self.currentQuestionIndex < self.questionsAmount - 1 {
            self.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        } else {
            showResult()
        }
    }
}
