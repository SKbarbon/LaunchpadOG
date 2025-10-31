import SwiftUI


struct SettingsPage: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("No settings yet.")
                }
            }
            .navigationTitle("Settings")
        }
        .frame(width: 500, height: 500)
    }
}
