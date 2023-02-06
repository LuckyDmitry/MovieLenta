import Foundation
import Combine

protocol ValueStore {
  associatedtype Value: Codable
  func save(_ value: Value) throws
  func load() throws -> Value?
  func erase() throws
}

// Type erasure
final class AnyValueStore<Value: Codable>: ValueStore {
  func save(_ value: Value) throws {
    try _save(value)
  }

  func load() throws -> Value? {
    try _load()
  }

  func erase() throws {
    try _erase()
  }


  private var _save: (Value) throws -> Void
  private var _load: () throws -> Value?
  private var _erase: () throws -> Void

  init<Store: ValueStore>(wrapped: Store) where Value == Store.Value {
    _save = wrapped.save(_:)
    _load = wrapped.load
    _erase = wrapped.erase
  }

}
