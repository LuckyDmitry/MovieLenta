import Foundation
import Combine

final class MovieDetailModel: ObservableObject {
  @Published var viewState: ViewState<MovieDetail> = .idle
  @Published var isSavedToFavotites: Bool = false

  private let movieLoader: MovieLoader
  private let currentMovieID: MovieID
  private let favoriteMovies: PersistableValue<[MovieDetail]>
  private let telemetry: Telemetry
  private var cancellables = Set<AnyCancellable>()

  init(
    movieID: MovieID,
    movieLoader: MovieLoader,
    favoriteMovies: PersistableValue<[MovieDetail]>,
    telemetry: Telemetry
  ) {
    self.movieLoader = movieLoader
    self.currentMovieID = movieID
    self.favoriteMovies = favoriteMovies
    self.telemetry = telemetry
    favoriteMovies
      .publisher
      .map { $0.contains(where: { $0.id == movieID }) }
      .assign(to: &$isSavedToFavotites)
  }

  func favoriteMovieButtonTapped() {
    guard case let .loaded(movieDetail) = viewState else {
      assertionFailure("Invalid state")
      return
    }
    favoriteMovies.update { movies in
      if let movieIndex = movies.firstIndex(where: { movieDetail.id == $0.id }) {
        movies.remove(at: movieIndex)
      } else {
        movies.append(movieDetail)
      }
    }
  }

  func viewAppeared() {
    viewState = .loading
    if let movie = favoriteMovies.value.first(where: { $0.id == currentMovieID }) {
      viewState = .loaded(movie)
      return
    }

    movieLoader
      .loadMovieDetails(currentMovieID)
      .sink { [weak self] completion in
        switch completion {
        case .failure(let error):
          self?.telemetry.logger.errorMessage(error.localizedDescription)
          self?.viewState = .error(.loadingError)
        case .finished:
          break
        }
      } receiveValue: { [weak self] movieDetail in
        self?.viewState = .loaded(movieDetail)
      }
      .store(in: &cancellables)
  }
}
