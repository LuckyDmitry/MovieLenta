import Foundation

struct Logger {
  var errorMessage: (_ message: String) -> Void
}

struct Telemetry {
  var logger: Logger
}
