import Foundation
import Combine
import SwiftUINavigation

final class MoviesListModel: ObservableObject {
  enum Destination: Equatable {
    case detail(MovieID)
  }

  private let movieLoader: MovieLoader
  private let telemetry: Telemetry
  private var bag = Set<AnyCancellable>()
  @Published private(set) var state: ViewState<[Movie]> = .idle
  @Published var destination: Destination?

  init(
    network: MovieLoader,
    telemetry: Telemetry,
    destination: Destination? = nil
  ) {
    self.movieLoader = network
    self.destination = destination
    self.telemetry = telemetry
  }

  func detailMovieItemTapped(_ movie: Movie) {
    destination = .detail(movie.id)
  }

  func viewAppeared() {
    guard state == .idle else { return }
    loadMovies()
  }

  func tryReloadMoviesButtonTapped() {
    loadMovies()
  }

  private func loadMovies() {
    state = .loading
    movieLoader.loadTopMovies()
      .sink { [weak self] error in
        switch error {
        case .failure(let error):
          self?.telemetry.logger.errorMessage(error.localizedDescription)
          self?.state = .error(.loadingError)
        case .finished: break
        }
      } receiveValue: { [weak self] movies in
        self?.state = .loaded(movies)
      }.store(in: &bag)
  }
}
