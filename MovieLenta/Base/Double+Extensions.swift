import Foundation

extension Double {
  var asMovieRating: String {
    String(format: "%.1f", self)
  }
}
