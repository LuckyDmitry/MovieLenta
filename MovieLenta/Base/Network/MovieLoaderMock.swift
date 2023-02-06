import Foundation
import Combine

struct MovieLoaderMocked: MovieLoader {
  var movieDetail: AnyPublisher<MovieDetail, Error> = Future {
    $0(.success(MovieDetail.mock))
  }.eraseToAnyPublisher()

  var topMovies: AnyPublisher<[Movie], Error> = Future {
    $0(.success(Movie.mocked))
  }.eraseToAnyPublisher()

  var moviesSuggestions: AnyPublisher<[SuggestMovie], Error> = Future {
    $0(.success(SuggestMovie.mockedSuggestions))
  }.eraseToAnyPublisher()

  func loadMovieDetails(_ movieID: MovieID) -> AnyPublisher<MovieDetail, Error> {
    movieDetail
  }

  func loadTopMovies() -> AnyPublisher<[Movie], Error> {
    topMovies
  }

  func loadMovieSuggestions(_ query: String) -> AnyPublisher<[SuggestMovie], Error> {
    moviesSuggestions
  }
}
