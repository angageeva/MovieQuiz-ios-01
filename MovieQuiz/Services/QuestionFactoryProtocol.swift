import Foundation

protocol QuestionFactoryProtocol {
    var delegate : QuestionFactoryDelegate? { get set }
    
    func requestNextQuestion()
    func refillUnshownIndexes()
    func loadData()
}
