import SwiftUI
import os

struct RootView: View {
  private enum Tabs: Hashable {
    case list, favorites
  }

  private let dependencies = Dependencies.real()

  @State private var currentTab = Tabs.list
  
  var body: some View {
    TabView(selection: $currentTab) {
      MoviesListRootView(dependencies: dependencies)
        .tabItem {
          VStack {
            Image(systemName: "film")
            Text("Movies")
          }
        }
        .tag(Tabs.list)
      FavoriteMoviesView(dependencies: dependencies)
        .tabItem {
          VStack {
            Image(systemName: "star")
            Text("Favorites")
          }
        }
        .tag(Tabs.favorites)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
