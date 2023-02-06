import Foundation

protocol DataStore {
  func save(_ data: Data) throws
  func load() -> Data?
  func erase() throws
}

final class FileDataStore: DataStore {

  private let fileUrl: URL
  init(fileUrl: URL) {
    self.fileUrl = fileUrl
  }

  convenience init<T>(_ type: T.Type) {
    let stringType = String(describing: type)
    self.init(fileUrl: .documentsDirectory.appending(path: stringType))
  }

  func save(_ data: Data) throws {
    try data.write(to: fileUrl, options: .atomic)
  }

  func load() -> Data? {
    guard FileManager.default.fileExists(atPath: fileUrl.relativePath) else {
      return nil
    }
    return FileManager.default.contents(atPath: fileUrl.relativePath)
  }

  func erase() throws {
    try FileManager.default.removeItem(at: fileUrl)
  }
}
