import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    let moviesLoader: MoviesLoading

    //добавления свойства с делегатом
    weak var delegate: QuestionFactoryDelegate?
    
    //массив фильмов, загруженных с сервера
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        //self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    // Массив индексов непоказанных вопросов
    private var unshownIndexes: [Int] = []

    // Функция заполнения массива неиспользуемых индексов
    func refillUnshownIndexes() {
        self.unshownIndexes = Array(0..<movies.count)
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            var correctAnswer: Bool
            
            do {
                imageData = try Data(contentsOf: movie.imageUrl)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let questionPhrase = ["больше","меньше"].randomElement()
            let comparingNumber = Int.random(in: 3...10)
            let text = "Рейтинг этого фильма \(questionPhrase!) , чем \(comparingNumber)?"
            if questionPhrase == "больше" {
                correctAnswer = rating > Float(comparingNumber)
            } else {
                correctAnswer = rating < Float(comparingNumber)
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies{ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items
                self.delegate?.didLoadDataFromserver()
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error)
            }
        }
    }
}
