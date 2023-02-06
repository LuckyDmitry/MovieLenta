@_private(sourceFile: "SuggestView.swift") import MovieLenta
import SwiftUINavigation
import Combine
import SwiftUI
import SwiftUI

extension SuggestView_Previews {
    @_dynamicReplacement(for: previews) private static var __preview__previews: some View {
        #sourceLocation(file: "/Users/i-dtrifonov/MyProjects/MovieLenta/MovieLenta/Suggests/SuggestView.swift", line: 107)
    SuggestView(searchQuery: Just(__designTimeString("#5617.[7].[0].property.[0].[0].arg[0].value.arg[0].value", fallback: "query")).eraseToAnyPublisher(), dependencies: .preview())
  
#sourceLocation()
    }
}

extension SuggestView {
    @_dynamicReplacement(for: suggestItemView(_:)) private func __preview__suggestItemView(_ suggest: SuggestMovie) -> some View {
        #sourceLocation(file: "/Users/i-dtrifonov/MyProjects/MovieLenta/MovieLenta/Suggests/SuggestView.swift", line: 78)
    HStack {
      CachingAsyncImage(url: suggest.posterURL) { image in
        image.resizable()
      } placeholder: {
        Color.gray
      }
      .frame(width: imageWidth, height: imageHeight)
      Text(suggest.title)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .contentShape(Rectangle())
    .padding()
    .onTapGesture {
      model.movieSuggestTapped(suggest)
    }
  
#sourceLocation()
    }
}

extension SuggestView {
    @_dynamicReplacement(for: emptyContent) private var __preview__emptyContent: some View {
        #sourceLocation(file: "/Users/i-dtrifonov/MyProjects/MovieLenta/MovieLenta/Suggests/SuggestView.swift", line: 70)
    VStack {
      Text(__designTimeString("#5617.[3].[5].property.[0].[0].arg[0].value.[0].arg[0].value", fallback: "Couldn't find anyting."))
      Text(__designTimeString("#5617.[3].[5].property.[0].[0].arg[0].value.[1].arg[0].value", fallback: "Try searching again using a different spelling or keyword."))
        .font(.system(size: errorDescriptionFontSize))
    }
  
#sourceLocation()
    }
}

extension SuggestView {
    @_dynamicReplacement(for: content(_:)) private func __preview__content(_ suggest: SuggestResult) -> AnyView {
        #sourceLocation(file: "/Users/i-dtrifonov/MyProjects/MovieLenta/MovieLenta/Suggests/SuggestView.swift", line: 50)
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
  
#sourceLocation()
    }
}

extension SuggestView {
    @_dynamicReplacement(for: body) private var __preview__body: some View {
        #sourceLocation(file: "/Users/i-dtrifonov/MyProjects/MovieLenta/MovieLenta/Suggests/SuggestView.swift", line: 24)
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
  
#sourceLocation()
    }
}

import struct MovieLenta.SuggestView
import struct MovieLenta.SuggestView_Previews
