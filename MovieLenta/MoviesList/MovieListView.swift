import SwiftUI
import Combine

struct MovieListView: View {
  @Environment(\.isSearching) var isSearching
  var movies: [Movie]
  var dependencies: Dependencies
  var searchQuery: AnyPublisher<String, Never>
  var onMovieTapped: (Movie) -> Void

  var body: some View {
    Group {
      if isSearching {
        SuggestView(
          searchQuery: searchQuery,
          dependencies: dependencies
        )
      } else {
        list(movies)
      }
    }
  }

  private func list(_ movies: [Movie]) -> AnyView {
    ScrollView {
      LazyVStack {
        ForEach(movies) { movie in
          VStack {
            MovieListLabel(movie: movie)
            Divider()
          }
          .contentShape(Rectangle())
          .onTapGesture {
            onMovieTapped(movie)
          }
          .padding(.horizontal)
        }
      }
    }
    .eraseToAnyView()
  }
}
