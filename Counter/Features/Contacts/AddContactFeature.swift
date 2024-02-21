import Foundation
import ComposableArchitecture

@Reducer
struct AddContactFeature {
  @ObservableState
  struct State: Equatable {
    var contact: Contact

    init(contact: Contact) {
      self.contact = contact
    }
  }
  enum Action {
    case cancelButtonTapped
    case delegate(Delegate)
    case saveButtonTapped
    case setName(String)
    @CasePathable
    enum Delegate: Equatable {
      case saveContact(Contact)
    }
  }
  @Dependency(\.dismiss) var dismiss
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .cancelButtonTapped:
        return .run { _ in await self.dismiss() }
      
      case .delegate:
        return .none
      
      case .saveButtonTapped:
        return .run { [contact = state.contact] send in
          await send(.delegate(.saveContact(contact)))
          await self.dismiss()
        }

      case .setName(let name):
        state.contact.name = name
        return .none
      }
    }
  }
}

import SwiftUI

struct AddContactView: View {
  @Bindable var store: StoreOf<AddContactFeature>

  var body: some View {
    Form {
      TextField("Name", text: $store.contact.name.sending(\.setName))
      Button("Save") {
        store.send(.saveButtonTapped)
      }
    }
    .toolbar {
      Button("Cancel") {
        store.send(.cancelButtonTapped)
      }
    }
  }
}

#Preview {
  AddContactView(store: StoreOf<AddContactFeature>(
    initialState:
      AddContactFeature.State(contact: Contact(id: UUID(), name: "Liam")),
    reducer: {
    AddContactFeature()
  }))
}
