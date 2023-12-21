import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle

    // создание @IBOutlet для картинки, текста и счётчика
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // создание @IBOutlet для кнопок "Да" и "Нет"
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    // создание переменной с индексом текущего вопроса, начальное значение 0
    var currentQuestionIndex = 0

    // переменной со счётчиком правильных ответов, начальное значение 0
    private var correctAnswers = 0
    
    //общее количество вопросов для квиза
    private let questionsAmount = 10
    
    //фабрика вопросов
    lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    
    //вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    //экземпляр класса StatisticServiceImplementation
    private var statisticService: StatisticService?

    // MARK: - Private functions
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")

        return questionStep
    }

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    // метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResult() {
        if currentQuestionIndex < questionsAmount - 1 {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
            } else {
                statisticService?.store(correct: correctAnswers, total: 10)
                let text = "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(statisticService?.gamesCount ?? 1)\nРекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? "(00.00.00 00:00"))\nСредняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%"
            let viewModelResult = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз") { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    questionFactory.refillUnshownIndexes()
                    questionFactory.requestNextQuestion()
                }
            let alertPresenter = AlertPresenter(delegate: self)
                
            alertPresenter.showResultAlert(alertModel: viewModelResult)
        }
    }

    // метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
            self.showNextQuestionOrResult()
        }
    }
    
    // MARK: - Actions
    
    // создание @IBAction функции для кнопок «Да» и «Нет»
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.delegate = self
        questionFactory.refillUnshownIndexes()
        questionFactory.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let currentQuestionViewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.show(quiz: currentQuestionViewModel)
        }
    }
}
