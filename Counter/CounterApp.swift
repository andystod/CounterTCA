import SwiftUI
import ComposableArchitecture

@main
struct CounterApp: App {
  static let store = Store(initialState: ContactsFeature.State(contacts: [
    Contact(id: UUID(), name: "Blob"),
    Contact(id: UUID(), name: "Blob Jr"),
    Contact(id: UUID(), name: "Blob Sr"),
  ])) {
    ContactsFeature()
      ._printChanges()
  }

  var body: some Scene {
    WindowGroup {
      ContactsView(store: CounterApp.store)
    }
  }
}
