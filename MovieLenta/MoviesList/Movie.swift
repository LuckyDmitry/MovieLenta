import Foundation

// MARK: Model

struct Movie: Codable, Hashable, Identifiable, ImageLoadable {
  let id: MovieID
  let title: String
  let overview: String?
  let posterPath: String?

  init(id: MovieID, title: String, posterPath: String?, overview: String?) {
    self.id = id
    self.title = title
    self.posterPath = posterPath
    self.overview = overview
  }
  
  enum CodingKeys: String, CodingKey {
    case id, title, overview
    case posterPath = "poster_path"
  }
}

// MARK: Mock

extension Movie {
  static let mock: Movie = Movie(id: 213, title: "Кот в сапогах", posterPath: "", overview: "Asdasdsadsa")

  static let mocked: [Movie] = [
    Movie(id: 213, title: "Кот в сапогах", posterPath: "", overview: "Asdasdsadsa"),
    Movie(id: 513, title: "Шрек", posterPath: "", overview: "Asdasdsadsa"),
    Movie(id: 313, title: "Мультик", posterPath: "", overview: "Asdasdsadsa"),
    Movie(id: 613, title: "Another", posterPath: "", overview: "Asdasdsadsa"),
    Movie(id: 513, title: "asdas", posterPath: "", overview: "Asdasdsadsa"),
  ]
}
