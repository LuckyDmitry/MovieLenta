import SwiftUI

// MARK: View

struct MovieDetailView: View {
  @StateObject private var viewModel: MovieDetailModel
  private let dependencies: Dependencies

  init(movieID: MovieID, dependencies: Dependencies) {
    self._viewModel = StateObject(
      wrappedValue: MovieDetailModel(
        movieID: movieID,
        movieLoader: dependencies.movieLoader,
        favoriteMovies: dependencies.favoriteMovies,
        telemetry: dependencies.telemetry
      ))
    self.dependencies = dependencies
  }

  var body: some View {
    switch viewModel.viewState {
    case .loading:
      return ProgressView().eraseToAnyView()
    case .loaded(let movieDetail):
      return content(movieDetail)
    case .idle:
      return idle
    case .error(let error):
      return Text(error.localizedDescription).eraseToAnyView()
    }
  }

  func content(_ movieDetail: MovieDetail) -> AnyView {
    GeometryReader { reader in
      ScrollView(.vertical, showsIndicators: false) {
        VStack {
          HStack {
            Spacer()
            CachingAsyncImage(url: movieDetail.posterURL) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
            } placeholder: {
              Color.gray
            }
            .frame(width: reader.size.width * imageWidthPercent)
            .frame(height: imageHeight)
            Spacer()
          }
          Text(movieDetail.title)
            .font(.title)
          Button(
            viewModel.isSavedToFavotites
            ? "Remove from favorites"
            : "Save to favorites") {
              viewModel.favoriteMovieButtonTapped()
            }
            .padding(.vertical, favoritesButtonVerticalPadding)
          Text(movieDetail.overview ?? "")
        }
        .padding()
      }
    }
    .eraseToAnyView()
  }

  var idle: AnyView {
    ClearView()
      .onAppear {
        viewModel.viewAppeared()
      }
      .eraseToAnyView()
  }
}

// MARK: Constants

private let imageHeight: CGFloat = 350
private let imageWidthPercent: CGFloat = 0.7
private let favoritesButtonVerticalPadding: CGFloat = 3

// MARK: Preview

struct MovieDetail_Previews: PreviewProvider {
  static var previews: some View {
    MovieDetailView(
      movieID: 12,
      dependencies: .preview()
    )
  }
}
