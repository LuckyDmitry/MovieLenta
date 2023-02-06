import Foundation

final class MockedDataStore: DataStore {
  var current: Data?

  func load() -> Data? {
    return current
  }

  func save(_ data: Data) throws {
    current = data
  }

  func erase() throws {
    current = nil
  }
}
