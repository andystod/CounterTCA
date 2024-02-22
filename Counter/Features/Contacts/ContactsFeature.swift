import Foundation
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
  let id: UUID
  var name: String
}

extension ContactsFeature {
  @Reducer(state: .equatable)
  enum Destination {
    case addContact(AddContactFeature)
    case alert(AlertState<ContactsFeature.Action.Alert>)
  }
}

@Reducer
struct ContactsFeature {
  @ObservableState
  struct State: Equatable {
    var contacts: IdentifiedArrayOf<Contact> = []
//    @Presents var addContact: AddContactFeature.State?
//    @Presents var alert: AlertState<Action.Alert>?
    @Presents var destination: Destination.State?
  }
  enum Action {
    case addButtonTapped
//    case addContact(PresentationAction<AddContactFeature.Action>)
//    case alert(PresentationAction<Alert>)
    case destination(PresentationAction<Destination.Action>)
    case deleteButtonTapped(id: Contact.ID)
    enum Alert: Equatable {
      case confirmDeletion(id: Contact.ID)
    }
  }
  @Dependency(\.uuid) var uuid
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.destination = .addContact(
          AddContactFeature.State(
            contact: Contact(id: self.uuid(), name: ""))
        )
        return .none

      case .destination(.presented(.addContact(.delegate(.saveContact(let contact))))):
        state.contacts.append(contact)
        return .none

      case .destination(.presented(.alert(.confirmDeletion(id: let id)))):
        state.contacts.remove(id: id)
        return .none

      case .destination:
        return .none

      case .deleteButtonTapped(id: let id):
        state.destination = .alert(.deleteConfirmation(id: id))
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

extension AlertState where Action == ContactsFeature.Action.Alert {
  static func deleteConfirmation(id: UUID) -> Self {
    Self {
      TextState("Are you sure?")
    } actions: {
      ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
        TextState("Delete")
      }
    }
  }
}

import SwiftUI

struct ContactsView: View {
  @Bindable var store: StoreOf<ContactsFeature>

  var body: some View {
    NavigationStack {
      List {
        ForEach(store.contacts) { contact in
          HStack {
            Text(contact.name)
            Spacer()
            Button(action: {
              store.send(.deleteButtonTapped(id: contact.id))
            }, label: {
              Image(systemName: "trash.fill")
                .foregroundStyle(Color.red)
            })
          }
        }
      }
      .navigationTitle("Contacts")
      .toolbar {
        Button {
          store.send(.addButtonTapped)
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .sheet(item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)) { addContactStore in
      NavigationStack {
        AddContactView(store: addContactStore)
      }
    }
    .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
  }
}

#Preview {
  ContactsView(
    store: Store(
      initialState: ContactsFeature.State(
        contacts: [
          Contact(id: UUID(), name: "Blob"),
          Contact(id: UUID(), name: "Blob Jr"),
          Contact(id: UUID(), name: "Blob Sr"),
        ]
      )
    ) {
      ContactsFeature()
    }
  )
}
