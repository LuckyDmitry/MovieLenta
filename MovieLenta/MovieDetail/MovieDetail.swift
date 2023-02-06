import Foundation

// MARK: Tag

enum MovieIDTag {}
typealias MovieID = Tagged<MovieIDTag, Int>

// MARK: Model

struct MovieDetail: Codable, Identifiable, ImageLoadable, Equatable {
  struct Genre: Codable, Equatable {
    var id: Int
    var name: String
  }
  var id: MovieID
  var title: String
  var overview: String?
  var budget: Int?
  var popularity: Double?
  var posterPath: String?
  var genres: [Genre]?
  var voteAverage: Double?

  enum CodingKeys: String, CodingKey {
    case id, title, overview, budget, popularity, genres
    case posterPath = "poster_path"
    case voteAverage = "vote_average"
  }
}

// MARK: Mock

extension MovieDetail {
  static let mock = MovieDetail(id: 12, title: "The Godfather", overview: "Interesting movie",
                                  budget: 100000, popularity: 7.6, posterPath: "thegodfather", genres: [.init(id: 12, name: "dasdsa")])
}
