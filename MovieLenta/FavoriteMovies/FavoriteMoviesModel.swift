import Foundation
import Combine

final class FavoriteMoviesModel: ObservableObject {
  enum Destination: Equatable {
    case detail(MovieID)
  }

  @Published private(set) var favoriteMovies: [MovieDetail] = []
  @Published var destination: Destination?
  private let favorites: PersistableValue<[MovieDetail]>
  private var cancellables = Set<AnyCancellable>()

  init(
    favorites: PersistableValue<[MovieDetail]>,
    destination: Destination? = nil
  ) {
    self.destination = destination
    self.favorites = favorites
    favorites
      .publisher
      .assign(to: &$favoriteMovies)
  }

  func removeFavoriteMovies(at indexSet: IndexSet) {
    favorites.update {
      $0.remove(atOffsets: indexSet)
    }
  }

  func movieTapped(_ movie: MovieDetail){
    destination = .detail(movie.id)
  }
}
