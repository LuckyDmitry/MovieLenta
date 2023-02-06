import Foundation
import Combine

enum SuggestResult: Equatable {
  case movies([SuggestMovie])
  case nothingFound
}

final class SuggestModel: ObservableObject {
  enum Destination: Equatable {
    case detail(MovieID)
  }

  @Published private(set) var viewState: ViewState<SuggestResult> = .idle
  @Published var destination: Destination?

  private let telemetry: Telemetry
  private var bag = Set<AnyCancellable>()

  init(
    movieLoader: MovieLoader,
    query: AnyPublisher<String, Never>,
    telemetry: Telemetry,
    destination: Destination? = nil
  ) {
    self.destination = destination
    self.telemetry = telemetry

    query
      .dropFirst()
      .removeDuplicates()
      .debounce(for: 0.3, scheduler: DispatchQueue.main)
      .handleEvents(receiveOutput: { [weak self] _ in
        self?.viewState = .loading
      })
      .map(movieLoader.loadMovieSuggestions)
      .switchToLatest()
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .failure(let error):
          self?.telemetry.logger.errorMessage(error.localizedDescription)
          self?.viewState = .error(.loadingError)
        case .finished:
          break
        }
      }, receiveValue: { [weak self] suggests in
        guard let self else { return }
        if suggests.isEmpty {
          self.viewState = .loaded(.nothingFound)
        } else {
          self.viewState = .loaded(.movies(suggests))
        }
      })
      .store(in: &bag)
  }

  func movieSuggestTapped(_ movie: SuggestMovie) {
    destination = .detail(movie.id)
  }
}
