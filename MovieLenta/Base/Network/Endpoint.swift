import Foundation

struct Endpoint {
  var baseURL: URL
  var path: String
  var timeout: TimeInterval = 15
  var queries: [URLQueryItem]
  func buildRequest() -> URL? {
    var requestUrl = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
    requestUrl?.queryItems = queries
    return requestUrl?.url
  }
}

