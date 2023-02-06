import Foundation
import Combine
import UIKit

final class ImageLoader: ObservableObject {
  @Published var image: UIImage?
  private let url: URL?
  private var cache: ImageCache
  private var cancellable: AnyCancellable?
  private var isLoading = false

  init(url: URL?, cache: ImageCache) {
    self.url = url
    self.cache = cache
  }

  func loadImage() {
    guard !isLoading,
          let url else { return }

    if let image = cache[url] {
      self.image = image
      return
    }

    cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .map { UIImage(data: $0.data) }
      .replaceError(with: nil)
      .handleEvents(receiveSubscription: { [weak self] _ in
        self?.isLoading = true
      }, receiveOutput: { [weak self] image in
        if let self, let url = self.url {
          self.cache[url] = image
        }
      }, receiveCompletion: { [weak self] _ in
        self?.isLoading = false
      }, receiveCancel: { [weak self] in
        self?.isLoading = false
      })
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in self?.image = $0 }
  }

  func cancel() {
    cancellable?.cancel()
  }

  deinit {
    cancel()
  }
}
