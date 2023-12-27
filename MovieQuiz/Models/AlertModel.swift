import Foundation

// Структура алерта
struct AlertModel {
    // заголовок алерта
    let title: String
    // сообщение алерта
    let message: String
    // текст кнопки алерта
    let buttonText: String

    var completion: (() -> Void)?
}
