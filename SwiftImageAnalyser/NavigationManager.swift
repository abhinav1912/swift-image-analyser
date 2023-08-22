//

import SwiftUI

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var path = NavigationPath()

    private init() {}
    
    func popToRoot() {
        path = NavigationPath()
    }

    func pushToStack(_ route: Route) {
        path.append(route)
    }
}

enum Route: Hashable {
    case prediction(result: [Prediction])
}
