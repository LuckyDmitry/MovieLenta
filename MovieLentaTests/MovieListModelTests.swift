import XCTest
import Combine
@testable import MovieLenta

final class MovieListModelTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }

  func test_idleStateOnModelInitialization() {
    let model = makeMovieListModel()

    XCTAssertEqual(model.state, .idle)
  }

  func test_loadingStateOnViewAppearEvent() {
    var loader = MovieLoaderMocked()
    loader.topMovies = Future { _ in

    }.eraseToAnyPublisher()
    let model = MoviesListModel(network: loader, telemetry: makeFakeTelemetry())

    model.viewAppeared()

    XCTAssertEqual(model.state, .loading)
  }

  func test_detailDestinationOnMovieTapped() {
    let movie = Movie.mock
    let movieLoader = makeMovieLoader(\.topMovies, predefined: .content([movie]))
    let model = makeMovieListModel(movieLoader: movieLoader)

    model.detailMovieItemTapped(movie)

    XCTAssertEqual(model.destination, .detail(movie.id))
  }

  func test_topMoviesLoadedOnAppear() {
    let movie = Movie.mock
    let movieLoader = makeMovieLoader(\.topMovies, predefined: .content([movie]))

    let model = makeMovieListModel(movieLoader: movieLoader)

    model.viewAppeared()

    XCTAssertEqual(model.state, .loaded([movie]))
  }

  func test_topMoviesErrorLoadedOnAppear() {
    var loader = MovieLoaderMocked()
    loader
      .topMovies = Future { $0(.failure(NetworkError.incorrectEndpoint)) }.eraseToAnyPublisher()

    let model = MoviesListModel(network: loader, telemetry: makeFakeTelemetry())

    model.viewAppeared()

    XCTAssertEqual(model.state, .error(.loadingError))
  }

  func test_loadingStateOnTryReloadPage() {
    let model = makeMovieListModel(movieLoader: makeInfiniteDetailMovieLoader(\.topMovies))

    model.tryReloadMoviesButtonTapped()

    XCTAssertEqual(model.state, .loading)
  }

  func test_errorMessageAddedToLogs() {
    var messageContainer: [String] = []

    let model = MoviesListModel(
      network: makeMovieLoader(\.topMovies, predefined: .error(NetworkError.incorrectEndpoint)),
      telemetry: makeFakeTelemetryWithContainer {
        messageContainer.append($0)
      })

    model.viewAppeared()

    XCTAssertTrue(!messageContainer.isEmpty)
  }
}
