import SwiftUI

class Router: ObservableObject {
  @Published var path: NavigationPath = NavigationPath()

  static let shared: Router = Router()
}
