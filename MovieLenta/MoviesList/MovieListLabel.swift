import SwiftUI

// MARK: View

struct MovieListLabel: View {
  var movie: Movie
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    HStack {
      CachingAsyncImage(url: movie.posterURL) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
      } placeholder: {
        Color.gray.opacity(0.6)
      }
      .frame(width: imageWidth, height: viewHeight)
      VStack(alignment: .leading) {
        Text(movie.title)
          .font(.title2)
        if let overview = movie.overview {
          Text(overview)
            .font(.system(size: overviewTextSize))
        }
      }
    }
    .frame(height: viewHeight)
  }
}

// MARK: Constants

private let viewHeight: CGFloat = 150
private let imageWidth = viewHeight / 2
private let overviewTextSize: CGFloat = 13

// MARK: Preview

struct MovieListLabel_Previews: PreviewProvider {
  static var previews: some View {
    MovieListLabel(movie: .mock)
  }
}
