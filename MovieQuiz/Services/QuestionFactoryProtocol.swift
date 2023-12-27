import Foundation

protocol QuestionFactoryProtocol {
    var delegate : QuestionFactoryDelegate? { get set }
    var moviesLoader: MoviesLoading? { get set }
    
    func requestNextQuestion()
    func refillUnshownIndexes()
    func loadData()
}
