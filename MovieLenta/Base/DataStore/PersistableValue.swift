import Foundation
import Combine

enum PersistableError: Error {
  case updateError
}

@dynamicMemberLookup
final class PersistableValue<Value: Codable> {

  private let syncQueue = DispatchQueue(
    label: "PersistableValueSyncQueue",
    qos: .userInitiated,
    attributes: .concurrent
  )
  private let valueStore: AnyValueStore<Value>

  private var _value: CurrentValueSubject<Value, Never>
  var publisher: AnyPublisher<Value, Never> {
    _value.eraseToAnyPublisher()
  }

  var value: Value {
    syncQueue.sync {
      _value.value
    }
  }

  init(value: Value, valueStore: AnyValueStore<Value>) {
    self._value = CurrentValueSubject(value)
    self.valueStore = valueStore
  }

  subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
    value[keyPath: keyPath]
  }

  func update(_ updater: (inout Value) throws -> Void) {
    do {
      var copyValue = self._value.value
      try updater(&copyValue)
      try syncQueue.sync(flags: .barrier) {
        try valueStore.save(copyValue)
      }
      _value.send(copyValue)
    } catch {
      assertionFailure()
    }
  }
}
