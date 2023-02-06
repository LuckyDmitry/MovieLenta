import Foundation

enum ViewState<Content> {
  case error(MovieError)
  case idle
  case loading
  case loaded(Content)
}

extension ViewState: Equatable where Content: Equatable {}
