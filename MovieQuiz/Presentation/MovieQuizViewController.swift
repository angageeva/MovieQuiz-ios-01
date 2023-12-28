import UIKit

final class MovieQuizViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // создание @IBOutlet для картинки, текста, индикатора загрузки и счётчика
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    // создание @IBOutlet для кнопок "Да" и "Нет"
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private let presenter = MovieQuizPresenter()
    //экземпляр класса StatisticServiceImplementation
    private var statisticService: StatisticService?

    // MARK: - Private functions

//    func didLoadDataFromServer() {
//        hideLoadingIndicator()
//        questionFactory.requestNextQuestion()
//    }
    
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }

//    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let questionNumber = "\(presenter.currentQuestionIndex + 1)/\(presenter.questionsAmount)"
//        let questionStep = QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: questionNumber)
//
//        return questionStep
//    }

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

        toggleButtonsEnabled(true)
    }

    // метод, который содержит логику перехода в один из сценариев
//    private func showNextQuestionOrResult() {
//        if presenter.currentQuestionIndex < presenter.questionsAmount - 1 {
//            presenter.currentQuestionIndex += 1
//            questionFactory.requestNextQuestion()
//        } else {
//            showResult()
//        }
//    }

    private func showResult() {
        statisticService?.store(correct: presenter.correctAnswers, total: 10)

        let viewModelResult = AlertModel(
            title: "Этот раунд окончен!",
            message: resultText(),
            buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else { return }

                presenter.restartGame()

//                questionFactory.refillUnshownIndexes()
//                questionFactory.requestNextQuestion()
            }
        let alertPresenter = AlertPresenter(delegate: self)

        alertPresenter.showResultAlert(alertModel: viewModelResult)
    }

    private func resultText() -> String {
        let result = "Ваш результат: \(presenter.correctAnswers)/10"
        let playedQuizzesAmount = "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 1)"
        let record = "Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? "(00.00.00 00:00"))"
        let accuracy = "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%"

        return [result, playedQuizzesAmount, record, accuracy].joined(separator: "\n")
    }

    // метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isYes: isCorrect)
        toggleButtonsEnabled(false)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
            //self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResult()
        }
    }
    
    private func toggleButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка",
                             message: message,
                             buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            
            //self.questionFactory.requestNextQuestion()
        }

        let alertPresenter = AlertPresenter(delegate: self)
        alertPresenter.showResultAlert(alertModel: model)
    }

    // MARK: - Actions

    // создание @IBAction функции для кнопок «Да» и «Нет»
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        //presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        //presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        //questionFactory.delegate = self
        //questionFactory.moviesLoader = MoviesLoader()
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        //questionFactory.loadData()
    }

//    func didRecieveNextQuestion(question: QuizQuestion?) {
//        presenter.didRecieveNextQuestion(question: question)
//    }
}
