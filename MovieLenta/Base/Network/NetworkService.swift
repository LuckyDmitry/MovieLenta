import Foundation
import Combine

enum NetworkError: Error {
  case incorrectEndpoint
}

extension NetworkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .incorrectEndpoint:
      return NSLocalizedString(
        "Incorrect EndPoint",
        comment: "Network error"
      )
    }
  }
}

protocol NetworkService {
  func makeRequest<RequestResult: Decodable>(endpoint: Endpoint) -> AnyPublisher<RequestResult, Error>
}

final class NetworkServiceImpl: NetworkService {
  static let shared = NetworkServiceImpl()

  func makeRequest<RequestResult: Decodable>(endpoint: Endpoint) -> AnyPublisher<RequestResult, Error> {
    guard let url = endpoint.buildRequest() else {
      return Fail(error: NetworkError.incorrectEndpoint).eraseToAnyPublisher()
    }
    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: RequestResult.self, decoder: JSONDecoder())
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
}

struct NetworkServiceMock: NetworkService {
  var resultData: Any = ""

  func makeRequest<RequestResult>(endpoint: Endpoint) -> AnyPublisher<RequestResult, Error> where RequestResult : Decodable {
    Future { promise in
      promise(.success(resultData as! RequestResult))
    }.eraseToAnyPublisher()
  }
}
