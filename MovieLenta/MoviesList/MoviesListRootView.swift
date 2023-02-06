import SwiftUI
import Combine
import SwiftUINavigation

// MARK: View

struct MoviesListRootView: View {
  @State private var searchQuery = ""
  @StateObject var model: MoviesListModel
  private let dependencies: Dependencies
  private let searchQuerySubject = CurrentValueSubject<String, Never>("")

  init(dependencies: Dependencies) {
    self._model = StateObject(wrappedValue: MoviesListModel(
      network: dependencies.movieLoader,
      telemetry: dependencies.telemetry
    ))
    self.dependencies = dependencies
  }

  var body: some View {
    NavigationStack {
      Group {
        switch model.state {
        case .idle:
          ClearView().eraseToAnyView()
            .onAppear(perform: model.viewAppeared)
        case .loading:
          ProgressView().eraseToAnyView()
        case .loaded(let movies):
          MovieListView(
            movies: movies,
            dependencies: dependencies,
            searchQuery: searchQuerySubject.eraseToAnyPublisher()) { movie in
            model.detailMovieItemTapped(movie)
          }
        case .error(let error):
          VStack {
            Text(error.localizedDescription)
            Button {
              model.tryReloadMoviesButtonTapped()
            } label: {
              Text("Reload movies")
            }
          }
          .eraseToAnyView()
        }
      }
      .navigationTitle("Movies")
      .navigationDestination(
        unwrapping: $model.destination,
        case: /MoviesListModel.Destination.detail) { $detailID in
          MovieDetailView(movieID: detailID, dependencies: dependencies)
        }
    }
    .searchable(text: $searchQuery)
    .onChange(of: searchQuery) { newValue in
      searchQuerySubject.send(newValue)
    }
  }
}

// MARK: Preview

struct MovieList_Previews: PreviewProvider {
  static var previews: some View {
    MoviesListRootView(dependencies: .preview())
  }
}
