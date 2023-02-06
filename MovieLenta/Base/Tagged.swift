import Foundation

@dynamicMemberLookup
struct Tagged<Tag, Value> {
  var value: Value
}

extension Tagged: Decodable where Value: Decodable {
  init(from decoder: Decoder) throws {
    do {
      self.init(value: try decoder.singleValueContainer().decode(Value.self))
    } catch {
      self.init(value: try .init(from: decoder))
    }
  }
}

extension Tagged: Hashable where Value: Hashable { }

extension Tagged: Encodable where Value: Encodable {
  func encode(to encoder: Encoder) throws {
    do {
      var container = encoder.singleValueContainer()
      try container.encode(self.value)
    } catch {
      try self.value.encode(to: encoder)
    }
  }
}

extension Tagged: Equatable where Value: Equatable {}

extension Tagged {
  public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
    self.value[keyPath: keyPath]
  }
}

extension Tagged: CustomStringConvertible {
  public var description: String {
    return String(describing: self.value)
  }
}

extension Tagged where Value == UUID {
  init() {
    self.init(value: UUID())
  }
}

extension Tagged: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
  typealias IntegerLiteralType = Value.IntegerLiteralType

  init(integerLiteral: IntegerLiteralType) {
    self.init(value: Value(integerLiteral: integerLiteral))
  }
}
