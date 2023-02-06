import SwiftUI
import Combine
import SwiftUINavigation

// MARK: View

struct SuggestView: View {
  @StateObject var model: SuggestModel
  private let dependencies: Dependencies

  init(
    searchQuery: AnyPublisher<String, Never>,
    dependencies: Dependencies
  ) {
    self.dependencies = dependencies
    self._model = StateObject(wrappedValue: SuggestModel(
      movieLoader: dependencies.movieLoader,
      query: searchQuery,
      telemetry: dependencies.telemetry
    ))
  }

  var body: some View {
    NavigationStack {
      Group {
        switch model.viewState {
        case .idle:
          EmptyView()
            .eraseToAnyView()
        case .loading:
          ProgressView()
            .eraseToAnyView()
        case .error(let error):
          Text(error.localizedDescription)
            .eraseToAnyView()
        case .loaded(let suggest):
          content(suggest)
        }
      }
      .navigationDestination(
        unwrapping: $model.destination,
        case: /SuggestModel.Destination.detail) { $movieID in
          MovieDetailView(movieID: movieID, dependencies: dependencies
          )
        }
    }
  }

  func content(_ suggest: SuggestResult) -> AnyView {
    Group {
      switch suggest {
      case .nothingFound:
        emptyContent
      case .movies(let suggests):
        ScrollView {
          LazyVStack(alignment: .leading) {
            ForEach(suggests) { suggest in
              VStack {
                suggestItemView(suggest)
                Divider()
              }
            }
          }
        }
      }
    }.eraseToAnyView()
  }

  var emptyContent: some View {
    VStack {
      Text("Couldn't find anyting.")
      Text("Try searching again using a different spelling or keyword.")
        .font(.system(size: errorDescriptionFontSize))
    }
  }

  func suggestItemView(_ suggest: SuggestMovie) -> some View {
    HStack {
      CachingAsyncImage(url: suggest.posterURL) { image in
        image.resizable()
      } placeholder: {
        Color.gray
      }
      .frame(width: imageWidth, height: imageHeight)
      VStack(alignment: .leading) {
        Text(suggest.title)
        if let release = suggest.release {
          Text(release)
            .font(.footnote)
        }
      }
      Spacer()
      if let vote = suggest.vote {
        Text(vote.asMovieRating)
          .bold()
      }
    }
    .frame(maxWidth: .infinity)
    .contentShape(Rectangle())
    .padding()
    .onTapGesture {
      model.movieSuggestTapped(suggest)
    }
  }
}

// MARK: Constants

private let imageHeight: CGFloat = 70
private let imageWidth: CGFloat = imageHeight * 0.75
private let errorDescriptionFontSize: CGFloat = 12

// MARK: Preview

struct SuggestView_Previews: PreviewProvider {
  static var previews: some View {
    SuggestView(searchQuery: Just("query").eraseToAnyPublisher(), dependencies: .preview())
  }
}
