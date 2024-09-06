//
//  ApiClient.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Foundation

protocol ApiClient {
    func getUsers(since: Int64, perPage: Int) async throws -> [GithubUser]
    func getUserInfo(login: String) async throws -> GithubUserInfo
    func getRepositories(login: String) async throws -> [GithubRepository]
}

extension ApiClient {
    func getUsers(since: Int64 = 0, perPage: Int = 30) async throws -> [GithubUser] {
        try await getUsers(since: since, perPage: perPage)
    }
}
