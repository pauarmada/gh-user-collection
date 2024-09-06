//
//  UserProfileViewModel.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Kingfisher
import SwiftUI

@MainActor
class UserProfileViewModel: ObservableObject {
    let user: GithubUser
    private let apiClient: ApiClient
    
    @Published var userInfo: GithubUserInfo? = nil
    @Published var repositories: [GithubRepository]? = nil
    
    init(user: GithubUser, apiClient: ApiClient) {
        self.user = user
        self.apiClient = apiClient
    }
    
    // Should be performed on demand so that it does not fetch data
    // even as the view model is created
    func fetch() async throws {
        _ = await [
            try self.fetchUserInfo(login: user.login),
            try self.fetchRepositories(login: user.login)
        ]
    }
    
    private func fetchUserInfo(login: String) async throws {
        userInfo = try await apiClient.getUserInfo(login: login)
    }
    
    private func fetchRepositories(login: String) async throws {
        let repositories = try await apiClient.getRepositories(login: login)
        
        // Filter out the forked repositories
        self.repositories = repositories.filter { !$0.fork }
    }
}
