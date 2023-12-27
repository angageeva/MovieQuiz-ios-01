import Foundation

// Структура для объекта ответа IMDb
struct MostPopularMovies: Codable {
    let errorMessage: String
    // массив всех фильмов и необходимой информации о них, полученных в ответе
    let items: [MostPopularMovie]
}
// Структура информации о фильме
struct MostPopularMovie: Codable {
    // название фильма
    let title: String
    // рейтинг фильма IMDb
    let rating: String
    // ссылка на изображение-постер фильма
    let imageUrl: URL

    // обновленная ссылка на изображение-постер с другим размером
    var resizedImageURL: URL {
        let urlString = imageUrl.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"

        guard let newUrl = URL(string: imageUrlString) else {
            return imageUrl
        }
        return newUrl
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageUrl = "image"
    }
}
