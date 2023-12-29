import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    //общее количество вопросов для квиза
    let questionsAmount = 10
    // создание переменной с индексом текущего вопроса, начальное значение 0
    var currentQuestionIndex = 0
    //вопрос, который видит пользователь
    var currentQuestion: QuizQuestion?
    // переменной со счётчиком правильных ответов, начальное значение 0
    var correctAnswers = 0

    //экземпляр класса StatisticServiceImplementation
    private let statisticService: StatisticService!
    //фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)

        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription

        viewController?.showNetworkError(message: message)
    }

    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func didAnswerCorrect(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0

        questionFactory?.refillUnshownIndexes()
        questionFactory?.requestNextQuestion()
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = (viewController?.imageFromData(imageData: model.image))!
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        let questionStep = QuizStepViewModel(
            image: image,
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

    func proceedWithAnswer(isCorrect: Bool) {
        didAnswerCorrect(isCorrect: isCorrect)
        viewController?.higlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.proceedToNextQuestionOrResults()
        }
    }

    // метод, который содержит логику перехода в один из сценариев
    func proceedToNextQuestionOrResults() {
        if self.currentQuestionIndex < self.questionsAmount - 1 {
            viewController?.showLoadingIndicator()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        } else {
            viewController?.showResultAlert()
        }
    }

    func showResult() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame
        let result = "Ваш результат: \(correctAnswers)/10"
        let playedQuizzesAmount = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        return [result, playedQuizzesAmount, record, accuracy].joined(separator: "\n")
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes

        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
