import XCTest
import Combine
@testable import MovieLenta

final class MovieDetailModelTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }

  func test_idleStateOnModelInit() {
    let model = makeMovieDetailModel()

    XCTAssertEqual(model.viewState, .idle)
  }

  func test_loadingStateOnViewAppeared() {
    let model = makeMovieDetailModel()

    model.viewAppeared()

    XCTAssertEqual(model.viewState, .loading)
  }

  func test_savedToFavoriteEnabledWithPresentedFavoriteMovies() {
    let model = makeMovieDetailModel(favoriteMovies: makeMockFavoriteMoviesStore([.mock]))

    XCTAssertTrue(model.isSavedToFavotites)
  }

  func test_savedToFavoriteDisabledWithPresentedFavoriteMovies() {
    let nextID = MovieID(value: movieID.value + 1)
    let favoriteMovies = makeMockFavoriteMoviesStore([.init(id: nextID, title: "Title")])
    let model = makeMovieDetailModel(favoriteMovies: favoriteMovies)

    XCTAssertFalse(model.isSavedToFavotites)
  }

  func test_savedToFavoriteDisabledWithEmptyFavoriteMovies() {
    let model = makeMovieDetailModel()

    XCTAssertFalse(model.isSavedToFavotites)
  }

  func test_saveToFavoriteMoviesOnSaveButtonTapped() {
    let favoriteMovies = makeMockFavoriteMoviesStore()
    let movieLoader = makeMovieLoader(\.movieDetail, predefined: .content(mock))
    let model = makeMovieDetailModel(
      movieLoader: movieLoader,
      favoriteMovies: favoriteMovies
    )

    model.viewAppeared()

    model.favoriteMovieButtonTapped()

    XCTAssertEqual(favoriteMovies.value, [mock])
  }

  func test_removeFromFavoriteMoviesOnRemoveButtonTapped() {
    let favoriteMovies = makeMockFavoriteMoviesStore([mock])
    let movieLoader = makeMovieLoader(\.movieDetail, predefined: .content(mock))

    let model = makeMovieDetailModel(
      movieLoader: movieLoader,
      favoriteMovies: favoriteMovies
    )

    model.viewAppeared()

    model.favoriteMovieButtonTapped()

    XCTAssertEqual(favoriteMovies.value, [])
  }

  func test_errorStateIfMovieLoaderReturnsError() {
    let movieLoader = makeMovieLoader(\.movieDetail, predefined: .error(NetworkError.incorrectEndpoint))

    let model = makeMovieDetailModel(
      movieLoader: movieLoader
    )

    model.viewAppeared()

    XCTAssertEqual(model.viewState, .error(.loadingError))
  }

  func test_loggerContainsErrorIfMovieLoaderReturnsError() {
    let error = NetworkError.incorrectEndpoint
    let movieLoader = makeMovieLoader(\.movieDetail, predefined: .error(error))

    var logContainer: [String] = []

    let model = makeMovieDetailModel(
      movieLoader: movieLoader,
      telemetry: makeFakeTelemetryWithContainer {
        logContainer.append($0)
      }
    )

    model.viewAppeared()

    XCTAssertEqual(logContainer, [error.localizedDescription])
  }

  func test_loadedStateIfMovieLoaderReturnsModel() {
    let model = makeMovieDetailModel(
      movieLoader: makeMovieLoader(\.movieDetail, predefined: .content(mock))
    )

    model.viewAppeared()

    XCTAssertEqual(model.viewState, .loaded(mock))
  }
}

private let mock = MovieDetail(id: movieID, title: "Title")
