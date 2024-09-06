//
//  GithubModels.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/05.
//

import Foundation

/**
 Each row should include the following elements;
　・User's avatar image
　・Username
 */
struct GithubUser: Decodable, Equatable {
    let id: Int64
    let login: String
    let avatarUrl: URL
}

/**
 Detailed information at the top of the list.
 ・Avatar image
 ・Username
 ・Full name
 ・Number of followers
 ・Number of followings
 */
struct GithubUserInfo: Decodable {
    let id: Int64
    let login: String
    let avatarUrl: URL
    let name: String
    let followers: Int
    let following: Int
}

/**
 Below, display a list of the user's original repositories (non-forked), including the following details:
 ・Repository name
 ・Programming language used
 ・Number of stars
 ・Description
 */
// Assumption: For now that this is only the "language" field
struct GithubRepository: Decodable, Equatable {
    let id: Int64
    let name: String
    let description: String?
    let fork: Bool
    let language: String?
    let stargazersCount: Int
    let htmlUrl: URL
}
