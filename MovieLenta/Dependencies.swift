import Foundation
import os

// MARK: Real dependencies
final class Dependencies {
  let networkLoader: NetworkService
  let movieLoader: MovieLoader
  let favoriteMovies: PersistableValue<[MovieDetail]>
  let telemetry: Telemetry

  init(
    networkLoader: NetworkService,
    movieLoader: MovieLoader,
    favoriteMovies: PersistableValue<[MovieDetail]>,
    telemetry: Telemetry
  ) {
    self.networkLoader = networkLoader
    self.movieLoader = movieLoader
    self.favoriteMovies = favoriteMovies
    self.telemetry = telemetry
  }
}

extension Dependencies {
  static let real: () -> Dependencies = {
    let network = NetworkServiceImpl()
    return Dependencies(
      networkLoader: network,
      movieLoader: MovieLoaderImpl(loader: network),
      favoriteMovies: makeFavoriteMoviesStore(),
      telemetry: makeRealTelemetry()
    )
  }

  static func makeFavoriteMoviesStore() -> PersistableValue<[MovieDetail]> {
    let store = PersistentValueStore<[MovieDetail]>(dataStore: FileDataStore(MovieDetail.self))
    let initial = (try? store.load()) ?? []
    return PersistableValue(value: initial, valueStore: store.eraseToAnyStore())
  }

  static func makeRealTelemetry() -> Telemetry {
    let osLogger = os.Logger(
      subsystem: Bundle.main.bundleIdentifier!,
      category: "LogEvents"
    )

    let logger = Logger { errorMessage in
      osLogger.error("\(errorMessage)")
    }
    return Telemetry(logger: logger)
  }
}

// MARK: Preview dependencies

extension Dependencies {
  static let preview: () -> Dependencies = {
    let network = NetworkServiceMock()
    return Dependencies(
      networkLoader: network,
      movieLoader: MovieLoaderMocked(),
      favoriteMovies: makePreviewFavoriteMoviesStore(),
      telemetry: makePreviewTelemetry()
    )
  }

  static func makePreviewFavoriteMoviesStore() -> PersistableValue<[MovieDetail]> {
    let store = PersistentValueStore<[MovieDetail]>(dataStore: MockedDataStore())
    return PersistableValue(value: [.mock], valueStore: store.eraseToAnyStore())
  }

  static func makePreviewTelemetry() -> Telemetry {
    let fakeLogger = Logger { errorMessage in
      print(errorMessage)
    }
    return Telemetry(logger: fakeLogger)
  }
}
