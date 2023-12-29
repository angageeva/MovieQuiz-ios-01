import XCTest
import UIKit
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {}
    func showResultAlert() {}
    func hideLoadingIndicator() {}
    func showLoadingIndicator() {}
    func showNetworkError(message: String) {}
    func higlightImageBorder(isCorrectAnswer: Bool) {}
    func imageFromData(imageData: Data) -> UIImage { UIImage() }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        // Given
        let viewcontrollerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewcontrollerMock)
        // When
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
