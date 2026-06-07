import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Pins", systemImage: "photo.on.rectangle.angled")
                }

            BoardsView()
                .tabItem {
                    Label("Boards", systemImage: "square.grid.2x2")
                }
        }
        .tint(.primary)
    }
}
