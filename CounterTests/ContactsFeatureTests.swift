//
//  ContactsFeatureTests.swift
//  CounterTests
//
//  Created by Andrew Stoddart on 21/02/2024.
//

import XCTest
import ComposableArchitecture
@testable import Counter

@MainActor
final class ContactsFeatureTests: XCTestCase {
  func testAddFlow() async {
    let store = TestStore(initialState: ContactsFeature.State()) {
      ContactsFeature()
    } withDependencies: {
      $0.uuid = .incrementing
    }

    // Send button tapped
    await store.send(.addButtonTapped) {
      $0.destination = .addContact(
        AddContactFeature.State(
          contact: Contact(id: UUID(0), name: "")
        )
      )
    }
    // Send set name
    await store.send(.destination(.presented(.addContact(.setName("Liam"))))) {
      $0.$destination[case: \.addContact]?.contact.name = "Liam"
    }
    // Send save button tapped
    await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
    // Receive delegate call to save contact
    await store.receive(
      \.destination.addContact.delegate.saveContact,
       Contact(id: UUID(0), name: "Liam")
    ) {
      $0.contacts = [
        Contact(id: UUID(0), name: "Liam")
      ]
    }
    // Receive destination dismiss
    await store.receive(
      \.destination.dismiss) {
        $0.destination = nil
      }
  }

  func testAddFlow_NonExhaustive() async {
    let store = TestStore(initialState: ContactsFeature.State()) {
      ContactsFeature()
    } withDependencies: {
      $0.uuid = .incrementing
    }

    store.exhaustivity = .off(showSkippedAssertions: true)

    await store.send(.addButtonTapped)
    await store.send(.destination(.presented(.addContact(.setName("Liam")))))
    await store.send(.destination(.presented(.addContact(.saveButtonTapped))))
    await store.skipReceivedActions()
    store.assert {
      $0.contacts = [
        Contact(id: UUID(0), name: "Liam")
      ]
      $0.destination = nil
    }
  }
}
