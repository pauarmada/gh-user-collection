//
//  UsersListViewModel.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Foundation

enum UsersListState {
    case loading
    case hasMore
    case complete
    case error
}

@MainActor
class UsersListViewModel: ObservableObject {
    private let apiClient: ApiClient
    @Published var users: [GithubUser] = []
    @Published var state: UsersListState = .loading
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
        
        // Once created, start the fetch
        Task {
            await reload()
        }
    }
    
    func reload() async {
        await fetch(since: 0)
    }
    
    func fetchMore() async {
        await fetch(since: users.last?.id ?? 0)
    }
    
    private func fetch(since: Int64) async {
        state = .loading
        
        do {
            // Add an artifical delay in order to see the spinner
            try await Task.sleep(nanoseconds: 500_000_000)
            let new = try await apiClient.getUsers(since: since)
            users += new
            // We are finished fetching if we cannot get any new ones
            state = new.isEmpty ? .complete : .hasMore
        } catch {
            state = .error
        }
    }
}
