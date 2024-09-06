//
//  GithubModelTests.swift
//  GhUserCollectionTests
//
//  Created by Paulus Armada on 2024/09/05.
//

import XCTest
@testable import GhUserCollection

final class GithubModelsTests: XCTestCase {
    
    private let decoder = GithubClient().decoder
    
    private func response(jsonString: String) -> Data {
        jsonString.data(using: .utf8)!
    }
    
    func test_decode_users() throws {
        let jsonString = """
        [
          {
            "login": "octocat",
            "id": 1,
            "avatar_url": "https://github.com/images/error/octocat_happy.gif"
          },
          {
            "login": "octocat2",
            "id": 2,
            "avatar_url": "https://github.com/images/error/octocat_happy2.gif"
          }
        ]
        """
        let users = try decoder.decode([GithubUser].self, from: response(jsonString: jsonString))
        XCTAssert(users.count == 2)
        
        let user1 = users.first!
        XCTAssertEqual(user1.id, 1)
        XCTAssertEqual(user1.login, "octocat")
        XCTAssertEqual(user1.avatarUrl, URL(string: "https://github.com/images/error/octocat_happy.gif"))
        
        let user2 = users.last!
        XCTAssertEqual(user2.id, 2)
        XCTAssertEqual(user2.login, "octocat2")
        XCTAssertEqual(user2.avatarUrl, URL(string: "https://github.com/images/error/octocat_happy2.gif"))
    }
    
    func test_decode_userInfo() throws {
        let jsonString = """
        {
          "login": "octocat",
          "id": 1,
          "avatar_url": "https://github.com/images/error/octocat_happy.gif",
          "name": "monalisa octocat",
          "followers": 20,
          "following": 0
        }
        """
        let userInfo = try decoder.decode(GithubUserInfo.self, from: response(jsonString: jsonString))
        
        XCTAssertEqual(userInfo.id, 1)
        XCTAssertEqual(userInfo.login, "octocat")
        XCTAssertEqual(userInfo.avatarUrl, URL(string: "https://github.com/images/error/octocat_happy.gif"))
        XCTAssertEqual(userInfo.name, "monalisa octocat")
        XCTAssertEqual(userInfo.followers, 20)
        XCTAssertEqual(userInfo.following, 0)
    }
    
    func test_decode_repositories() throws {
        let jsonString = """
        [
          {
            "id": 1296269,
            "name": "min-fields",
            "html_url": "https://github.com/octocat/Hello-World",
            "description": null,
            "fork": false,
            "language": null,
            "stargazers_count": 0,
          },
          {
            "id": 1296270,
            "name": "full-description",
            "html_url": "https://github.com/octocat/Hello-World2",
            "description": "This your first repo!",
            "fork": true,
            "language": "swift",
            "stargazers_count": 80
          }
        ]
        """
        let repositories = try decoder.decode([GithubRepository].self, from: response(jsonString: jsonString))
        
        let repo1 = repositories.first!
        XCTAssertEqual(repo1.id, 1296269)
        XCTAssertEqual(repo1.name, "min-fields")
        XCTAssertNil(repo1.description)
        XCTAssertFalse(repo1.fork)
        XCTAssertNil(repo1.language)
        XCTAssertEqual(repo1.stargazersCount, 0)
        XCTAssertEqual(repo1.htmlUrl, URL(string: "https://github.com/octocat/Hello-World"))
        
        let repo2 = repositories.last!
        XCTAssertEqual(repo2.id, 1296270)
        XCTAssertEqual(repo2.name, "full-description")
        XCTAssertEqual(repo2.description, "This your first repo!")
        XCTAssertTrue(repo2.fork)
        XCTAssertEqual(repo2.language, "swift")
        XCTAssertEqual(repo2.stargazersCount, 80)
        XCTAssertEqual(repo2.htmlUrl, URL(string: "https://github.com/octocat/Hello-World2"))
    }
}
