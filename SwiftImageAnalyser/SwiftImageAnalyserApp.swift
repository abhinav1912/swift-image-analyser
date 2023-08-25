//

import SwiftUI

@main
struct SwiftImageAnalyserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ClassificationViewModel(userPreferences: UserPreferences.sharedInstance))
        }
    }
}
