import Foundation

final class PersistentValueStore<Value: Codable>: ValueStore {
  private let dataStore: DataStore

  init(dataStore: DataStore) {
    self.dataStore = dataStore
  }

  func save(_ value: Value) throws {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .binary
    let data = try encoder.encode(value)
    try dataStore.save(data)
  }

  func load() throws -> Value? {
    guard let data = dataStore.load() else {
      return nil
    }
    let decoder = PropertyListDecoder()
    do {
      let decodedValue = try decoder.decode(Value.self, from: data)
      return decodedValue
    } catch {
      try erase()
      return nil
    }
  }

  func erase() throws {
    try dataStore.erase()
  }
}

extension PersistentValueStore {
  func eraseToAnyStore() -> AnyValueStore<Value> {
    AnyValueStore(wrapped: self)
  }
}
