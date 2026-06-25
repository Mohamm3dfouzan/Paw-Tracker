import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Pets", systemImage: "pawprint.fill") {
                PetsListView()
            }
            Tab("Health", systemImage: "heart.text.square.fill") {
                HealthHubView()
            }
            Tab("Food", systemImage: "fork.knife") {
                FoodHubView()
            }
            Tab("Photos", systemImage: "photo.on.rectangle.angled") {
                PhotosHubView()
            }
            Tab("Profile", systemImage: "person.crop.circle") {
                ProfileView()
            }
        }
    }
}
