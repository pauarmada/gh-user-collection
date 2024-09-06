//
//  GithubClientTests.swift
//  GhUserCollectionTests
//
//  Created by Paulus Armada on 2024/09/05.
//

import XCTest
@testable import GhUserCollection

final class GithubClientTests: XCTestCase {
    
    private func client(customAccessToken: String? = nil) -> GithubClient {
        if let customAccessToken {
            GithubClient(accessToken: customAccessToken)
        } else {
            GithubClient()
        }
    }
    
    func test_invalidAccessToken() async {
        do {
            _ = try await client(customAccessToken: "this_dont_work").getUsers(since: 0, perPage: 1)
            XCTFail("Should not succeed")
        } catch {
            // No-Op
        }
    }
    
    func test_getUsers() async throws {
        let client = client()
        let users = try await client.getUsers(perPage: 1)
        XCTAssert(users.count == 1)
        
        // Paging should work
        let user = users.first!
        let nextUsers = try await client.getUsers(since: user.id, perPage: 1)
        XCTAssert(nextUsers.count == 1)
        
        XCTAssertNotEqual(users.first, nextUsers.first)
    }
    
    func test_getUserInfo() async throws {
        let client = client()
        let users = try await client.getUsers(perPage: 2)
        XCTAssert(users.count > 1)
        
        let user = users.first!
        let userInfo = try await client.getUserInfo(login: user.login)
        XCTAssertEqual(user.id, userInfo.id)
    }
    
    func test_getRepositories() async throws {
        let client = client()
        let users = try await client.getUsers(perPage: 2)
        XCTAssert(users.count > 1)
        
        let user = users.first!
        _ = try await client.getRepositories(login: user.login)
    }
}
