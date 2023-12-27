import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let questionPhrases = ["больше", "меньше"]
    
    var moviesLoader: MoviesLoading?

    //добавления свойства с делегатом
    weak var delegate: QuestionFactoryDelegate?
    
    //массив фильмов, загруженных с сервера
    private var movies: [MostPopularMovie] = []
    
    // Массив индексов непоказанных вопросов
    private var unshownIndexes: [Int] = []

    // Функция заполнения массива неиспользуемых индексов
    func refillUnshownIndexes() {
        self.unshownIndexes = Array(0..<movies.count)
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = unshownIndexes.randomElement() ?? 0
            let question = nextQuestion(index: index)
 
            self.unshownIndexes = unshownIndexes.filter { $0 != index }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }

    func nextQuestion(index: Int) -> QuizQuestion? {
        guard let movie = self.movies[safe: index] else { return nil }

        let rating = Float(movie.rating) ?? 0
        let questionPhrase = questionPhrases.randomElement()
        let comparingNumber = Int.random(in: 6...9)
        let text = "Рейтинг этого фильма \(questionPhrase!) , чем \(comparingNumber)?"

        let isRatingBigger = rating > Float(comparingNumber)
        let correctAnswer = questionPhrase == "больше" ? isRatingBigger : !isRatingBigger

        var imageData = Data()
        do {
            imageData = try Data(contentsOf: movie.resizedImageURL)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.didFailToLoadData(with: error)
            }
        }

        return QuizQuestion(image: imageData,
                            text: text,
                            correctAnswer: correctAnswer)
    }

    func loadData() {
        moviesLoader?.loadMovies{ [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let mostPopularMovies):
                    self.setMoviesFromData(movies: mostPopularMovies.items)
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    private func setMoviesFromData(movies: [MostPopularMovie]) {
        self.movies = movies
 
        refillUnshownIndexes()
        delegate?.didLoadDataFromServer()
    }
}
