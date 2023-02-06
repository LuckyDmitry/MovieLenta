import XCTest
import Combine
@testable import MovieLenta

// MARK: Helpers

let movieID: MovieID = 12
let mockDetail = MovieDetail(id: movieID, title: "Mock title")

enum MovieLoaderType<Content> {
  case content(Content)
  case error(Error)
}

// MARK: Model factories

func makeMovieDetailModel(
  id: MovieID? = nil,
  movieLoader: MovieLoader? = nil,
  favoriteMovies: PersistableValue<[MovieDetail]>? = nil,
  telemetry: Telemetry? = nil
) -> MovieDetailModel {
  MovieDetailModel(
    movieID: id ?? movieID,
    movieLoader: movieLoader ?? makeInfiniteDetailMovieLoader(\.movieDetail),
    favoriteMovies: favoriteMovies ?? makeMockFavoriteMoviesStore(),
    telemetry: telemetry ?? makeFakeTelemetry()
  )
}

func makeMovieListModel(
  movieLoader: MovieLoader? = nil,
  telemetry: Telemetry? = nil,
  destination: MoviesListModel.Destination? = nil
) -> MoviesListModel {
  MoviesListModel(
    network: movieLoader ?? makeInfiniteDetailMovieLoader(\.topMovies),
    telemetry: telemetry ?? makeFakeTelemetry(),
    destination: destination
  )
}

func makeSuggestModel(
  movieLoader: MovieLoader? = nil,
  query: AnyPublisher<String, Never>? = nil,
  telemetry: Telemetry? = nil,
  destination: SuggestModel.Destination? = nil
) -> SuggestModel {
  SuggestModel(
    movieLoader: movieLoader ?? makeInfiniteDetailMovieLoader(\.moviesSuggestions),
    query: query ?? Just("").eraseToAnyPublisher(),
    telemetry: telemetry ?? makeFakeTelemetry(),
    destination: destination
  )
}

// MARK: Dependency mock factories

func makeFakeTelemetry() -> Telemetry {
  Telemetry(logger: Logger(errorMessage: { _ in }))
}

func makeFakeTelemetryWithContainer(_ updateContainer: @escaping (String) -> Void) -> Telemetry {
  Telemetry(logger: Logger(errorMessage: { message in
    updateContainer(message)
  }))
}

func makeMockFavoriteMoviesStore(_ predefined: [MovieDetail] = []) -> PersistableValue<[MovieDetail]> {
  let store = PersistentValueStore<[MovieDetail]>(dataStore: MockedDataStore())
  return PersistableValue(value: predefined, valueStore: store.eraseToAnyStore())
}

func makeMovieLoader<T, Output>(
  _ referenceKeyPath: WritableKeyPath<MovieLoaderMocked, T>,
  predefined: MovieLoaderType<Output>
) -> MovieLoader where T == AnyPublisher<Output, Error> {
  var mocked = MovieLoaderMocked()
  mocked[keyPath: referenceKeyPath] = Future<Output, Error> {
    switch predefined {
    case .content(let content):
      $0(.success(content))
    case .error(let error):
      $0(.failure(error))
    }
  }.eraseToAnyPublisher()
  return mocked
}

func makeInfiniteDetailMovieLoader<T, Output, Failure>(
  _ referenceKeyPath: WritableKeyPath<MovieLoaderMocked, T>
) -> MovieLoader where T == AnyPublisher<Output, Failure>,
                       T.Output == Output, T.Failure == Failure {
  var mocked = MovieLoaderMocked()
  mocked[keyPath: referenceKeyPath] = Future<Output, Failure> { _ in }.eraseToAnyPublisher()
  return mocked
}
