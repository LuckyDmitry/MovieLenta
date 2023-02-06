import Foundation

enum MovieError: Error {
  case loadingError
}

extension MovieError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .loadingError:
      return "Error happened while loading, try reload page"
    }
  }
}
