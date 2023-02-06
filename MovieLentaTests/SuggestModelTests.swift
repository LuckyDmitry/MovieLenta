import XCTest
import Combine
@testable import MovieLenta

final class SuggestModelTests: XCTestCase {
  var query: CurrentValueSubject<String, Never>!

  var suggestQuery: AnyPublisher<String, Never> {
    query.eraseToAnyPublisher()
  }

  var infiniteLoader: MovieLoader {
    makeInfiniteDetailMovieLoader(\.moviesSuggestions)
  }

  override func setUp() {
    super.setUp()
    query = CurrentValueSubject<String, Never>("")
  }

  func test_idleStateOnInitModel() {
    let model = makeSuggestModel()

    XCTAssertEqual(model.viewState, .idle)
  }

  func test_loadingStateOnTyping() {
    let model = makeSuggestModel(query: suggestQuery)

    let expectation = expectation(description: "Loading")

    let cancellable = model
      .$viewState
      .sink { state in
        if state == .loading {
          expectation.fulfill()
        }
      }

    query.send("Some")

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(model.viewState, .loading)
  }

  func test_nilDestinationOnModelInitialization() {
    let model = makeSuggestModel(query: suggestQuery)

    XCTAssertEqual(model.destination, nil)
  }

  func test_detailDestinationOnSuggestionTap() {
    let model = makeSuggestModel(
      movieLoader: makeMovieLoader(\.moviesSuggestions, predefined: .content([suggest])),
      query: suggestQuery
    )

    query.send("Some")
    model.movieSuggestTapped(suggest)

    XCTAssertEqual(model.destination, .detail(suggest.id))
  }
}

private let suggest: SuggestMovie = .init(id: movieID, title: "Some title")

