//
//  GithubClient.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/05.
//

import Alamofire
import ArkanaKeys
import Foundation

class GithubClient: ApiClient {
    private let baseUrl: String
    private let headers: HTTPHeaders
    
    // Use a custom decoder to take care of the snake case
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(accessToken: String = ArkanaKeys.Global().githubToken) {
        self.baseUrl = "https://api.github.com"
        // Attach the authorization token to the headers
        self.headers = HTTPHeaders(
            [
                HTTPHeader(name: "Authorization", value: "Bearer \(accessToken)"),
                HTTPHeader(name: "Accept", value: "application/vnd.github+json"),
            ]
        )
    }
    
    // https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users
    func getUsers(since: Int64, perPage: Int) async throws -> [GithubUser] {
        try await get("\(baseUrl)/users?per_page=\(perPage)&since=\(since)")
    }
    
    // https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user-using-their-id
    func getUserInfo(login: String) async throws -> GithubUserInfo {
        try await get("\(baseUrl)/users/\(login)")
    }
    
    // https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user
    func getRepositories(login: String) async throws -> [GithubRepository] {
        try await get("\(baseUrl)/users/\(login)/repos")
    }

    private func get<T>(_ convertible: URLConvertible) async throws -> T where T: Decodable {
        try await AF
            .request(
                convertible,
                headers: headers
            )
            .serializingResponse(
                using: DecodableResponseSerializer<T>(decoder: decoder)
            )
            .value
    }
}

