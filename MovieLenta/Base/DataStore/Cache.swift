import Foundation
import UIKit

protocol ImageCache {
  subscript(key: URL) -> UIImage? { get set }
}

final class InMemoryImageCache: ImageCache {
  static let shared = InMemoryImageCache()
  private let cache = NSCache<NSString, UIImage>()

  subscript(key: URL) -> UIImage? {
    get {
      cache.object(forKey: key.asNSString)
    }
    set {
      if let newValue {
        cache.setObject(newValue, forKey: key.asNSString)
      } else {
        cache.removeObject(forKey: key.asNSString)
      }
    }
  }
}

extension URL {
  fileprivate var asNSString: NSString {
    NSString(string: self.absoluteString)
  }
}
