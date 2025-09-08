import AlertKit

@MainActor
struct LoadingAlertController {
  static var shared = LoadingAlertController()

  private var isLoadingVisible: Bool = false
  private var loadingView: AlertAppleMusic16View?

  mutating func present() {
    guard isLoadingVisible == false else { return }

    let view = AlertAppleMusic16View(title: "Loading...", subtitle: nil, icon: .spinnerLarge)
    view.haptic = nil
    // For spinner icons, AlertKit already sets dismissInTime = false and dismissByTap = false

    AlertKitAPI.present(view: view)
    loadingView = view
    isLoadingVisible = true
  }

  mutating func dismiss() {
    guard isLoadingVisible else { return }

    loadingView?.dismiss()
    loadingView = nil
    isLoadingVisible = false
  }
}
