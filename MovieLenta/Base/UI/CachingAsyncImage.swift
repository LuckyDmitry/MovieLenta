import SwiftUI
import Combine

struct CachingAsyncImage<Placeholder: View>: View {
  @StateObject var loader: ImageLoader
  private var placeholder: Placeholder
  private var image: (Image) -> any View

  init(
    url: URL?,
    image: @escaping (Image) -> any View,
    @ViewBuilder placeholder: () -> Placeholder) {
      self._loader = StateObject(wrappedValue: ImageLoader(
        url: url,
        cache: InMemoryImageCache.shared
      ))
      self.image = image
      self.placeholder = placeholder()
    }

  var body: some View {
    Group {
      if let image = loader.image {
        self.image(Image(uiImage: image)).eraseToAnyView()
      } else {
        placeholder
      }
    }.onAppear(perform: loader.loadImage)
  }
}
