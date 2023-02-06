import SwiftUI

// MARK: View

struct FavoriteMoviesView: View {
  @StateObject var model: FavoriteMoviesModel
  private let dependencies: Dependencies

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    self._model = StateObject(
      wrappedValue: FavoriteMoviesModel(
        favorites: dependencies.favoriteMovies
      )
    )
  }
  
  var body: some View {
    NavigationView {
      Group {
        if !model.favoriteMovies.isEmpty {
          List {
            ForEach(model.favoriteMovies) { movie in
              NavigationLink {
                MovieDetailView(movieID: movie.id, dependencies: dependencies)
              } label: {
                Text(movie.title)
              }
            }
            .onDelete(perform: model.removeFavoriteMovies)
          }
        } else {
          Text("Here you will see your list of favorite movies")
        }
      }
      .navigationTitle("Favorites")
    }
  }
}

// MARK: Preview

struct FavoriteMoviesView_Previews: PreviewProvider {
  static var previews: some View {
    FavoriteMoviesView(dependencies: .preview())
  }
}
