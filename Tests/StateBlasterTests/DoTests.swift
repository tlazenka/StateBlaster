//
//  DoTests.swift
//  Racros
//
//  Created by Francis Lazenka on 9/24/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@MainActor final class DoTests: XCTestCase {
    var service: ServiceProtocol!

    override func setUp() async throws {
        service = ServiceMock()
    }

    func testBasics() async throws {
        func fetchCurrentUser() -> Result<(User, Door), ServiceFailure> {
            switch service.fetchUser() {
            case .success(let user):
                switch service.fetchDoor(for: user.id) {
                case .success(let door):
                    .success((user, door))
                case .failure(let failure):
                    .failure(failure)
                }
            case .failure(let failure):
                .failure(failure)
            }
        }
        switch fetchCurrentUser() {
        case .failure(let failure):
            XCTFail(failure.localizedDescription)
        case .success((_, _)):
            break
        }
    }
}

enum ServiceFailure: Error {

}

struct UserID {
    let rawValue: UUID
}

struct DoorID {
    let rawValue: UUID
}

struct User {
    let id: UserID
}

struct Door {
    let id: DoorID
}

protocol ServiceProtocol {
    func fetchUser() -> Result<User, ServiceFailure>

    func fetchDoor(for userID: UserID) -> Result<Door, ServiceFailure>
}

final class ServiceMock: ServiceProtocol {
    func fetchUser() -> Result<User, ServiceFailure> {
        .success(User(id: UserID(rawValue: UUID())))
    }

    func fetchDoor(for userID: UserID) -> Result<Door, ServiceFailure> {
        .success(Door(id: DoorID(rawValue: UUID())))
    }

}
