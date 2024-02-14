import SwiftUI
import ComposableArchitecture

@main
struct CounterApp: App {
  static let store = Store(initialState: ContactsFeature.State()) {
    ContactsFeature()
      ._printChanges()
  }

  var body: some Scene {
    WindowGroup {
      ContactsView(store: CounterApp.store)
    }
  }
}
