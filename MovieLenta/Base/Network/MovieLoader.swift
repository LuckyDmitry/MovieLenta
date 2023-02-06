import Foundation
import Combine

protocol MovieLoader {
  func loadTopMovies() -> AnyPublisher<[Movie], Error>
  func loadMovieDetails(_ movieID: MovieID) -> AnyPublisher<MovieDetail, Error>
  func loadMovieSuggestions(_ query: String) -> AnyPublisher<[SuggestMovie], Error>
}

struct MovieLoaderImpl: MovieLoader {
  let loader: NetworkService

  func loadTopMovies() -> AnyPublisher<[Movie], Error> {
    let endpoint = buildEndpoint(atPath: "/movie/top_rated")
    let wrapped: AnyPublisher<PagedResultsWrapper<Movie>, Error> = loader
      .makeRequest(endpoint: endpoint)
    return wrapped.map(\.results).eraseToAnyPublisher()
  }

  func loadMovieDetails(_ movieID: MovieID) -> AnyPublisher<MovieDetail, Error> {
    let endpoint = buildEndpoint(atPath: "/movie/\(movieID)")
    return loader.makeRequest(endpoint: endpoint)
  }

  func loadMovieSuggestions(_ query: String) -> AnyPublisher<[SuggestMovie], Error> {
    guard !query.isEmpty else {
      return Future { $0(.success([])) }.eraseToAnyPublisher()
    }
    let endpoint = buildEndpoint(
      atPath: "search/movie",
      queries: [.init(name: "query", value: query)]
    )
    let wrapped: AnyPublisher<PagedResultsWrapper<SuggestMovie>, Error> = loader
      .makeRequest(endpoint: endpoint)
    return wrapped.map(\.results).eraseToAnyPublisher()
  }

  private func buildEndpoint(atPath path: String, queries: [URLQueryItem] = []) -> Endpoint {
    Endpoint(baseURL: baseURL, path: path, queries: [apiQeury] + queries)
  }
}

extension ImageLoadable {
  var posterURL: URL? {
    guard let posterPath else { return nil }
    return smallImageBaseURL?.appending(path: posterPath)
  }
}

private let baseURL: URL = URL(string: "https://api.themoviedb.org/3")!
private let smallImageBaseURL = URL(string: "https://image.tmdb.org/t/p/original/")
private let apiQeury: URLQueryItem = .init(name: "api_key", value: "44eb0f443b2291eebf8a341891124ccc")


private struct PagedResultsWrapper<Wrapped: Decodable>: Decodable {
  var page: Int
  var results: [Wrapped]
}
