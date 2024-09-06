//
//  UsersListViewModel.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Combine
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
    
    @Published var isSearching = false
    @Published var searchedUser: GithubUser?
    
    private var searchTextSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
        
        // Once created, start the fetch
        Task {
            await reload()
        }
        
        // Debounce user input to minimize network calls
        searchTextSubject
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                Task {
                    // Perform search
                    await self?.performSearch(searchText: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    func reload() async {
        await fetch(since: 0)
    }
    
    func fetchMore() async {
        await fetch(since: users.last?.id ?? 0)
    }
    
    func search(searchText: String) {
        isSearching = true
        searchedUser = nil
        searchTextSubject.send(searchText)
    }
    
    private func performSearch(searchText: String) async {
        if let userInfo = try? await apiClient.getUserInfo(login: searchText) {
            searchedUser = GithubUser(id: userInfo.id, login: userInfo.login, avatarUrl: userInfo.avatarUrl)
        }
        
        // Reset the searching flag
        isSearching = false
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
