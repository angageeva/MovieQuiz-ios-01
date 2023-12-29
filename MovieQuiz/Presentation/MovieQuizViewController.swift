import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResultAlert()
    func higlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func imageFromData(imageData: Data) -> UIImage
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
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

    private var presenter: MovieQuizPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Actions

    // создание @IBAction функции для кнопок «Да» и «Нет»
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    // MARK: - Functions

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        hideLoadingIndicator()
        toggleButtonsEnabled(true)
    }

    func showResultAlert() {
        let message = presenter.showResult()

        let viewModelResult = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else { return }

                presenter.restartGame()
            }
        let alertPresenter = AlertPresenter(delegate: self)

        alertPresenter.showResultAlert(alertModel: viewModelResult)
    }

    // метод, который меняет цвет рамки
    func higlightImageBorder(isCorrectAnswer: Bool) {
        toggleButtonsEnabled(false)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка",
                             message: message,
                             buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }

        let alertPresenter = AlertPresenter(delegate: self)
        alertPresenter.showResultAlert(alertModel: model)
    }

    func imageFromData(imageData: Data) -> UIImage {
        UIImage(data: imageData) ?? UIImage()
    }
    
    private func toggleButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}
