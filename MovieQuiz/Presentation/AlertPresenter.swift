import UIKit

final class AlertPresenter {
    private weak var delegate: UIViewController?

    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }

    func showResultAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        // константа с кнопкой для системного алерта, которая перезапускает игру
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in alertModel.completion?()
        }
        alert.addAction(action)

        delegate?.present(alert, animated: true, completion: nil)
    }
}
