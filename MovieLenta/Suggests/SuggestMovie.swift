import Foundation

struct SuggestMovie: Identifiable, Codable, Equatable, ImageLoadable {
  var id: MovieID
  var title: String
  var posterPath: String?
  var vote: Double?
  var release: String?

  enum CodingKeys: String, CodingKey {
    case id, title
    case posterPath = "poster_path"
    case vote = "vote_average"
    case release = "release_date"
  }
}

extension SuggestMovie {
  static let mockedSuggestions: [SuggestMovie] = [
    .init(id: 12, title: "Shrek"),
    .init(id: 13, title: "Invisible"),
    .init(id: 14, title: "Acceptance")
  ]
}
