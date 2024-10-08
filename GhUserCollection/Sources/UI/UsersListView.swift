//
//  UsersListView.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Kingfisher
import SwiftUI

struct UsersListView: View {
    @ObservedObject var viewModel: UsersListViewModel
    @EnvironmentObject var dependencyGraph: DependencyGraph
    
    @State var searchText = ""
    @State var isSearchPresented = false
    
    var body: some View {
        List {
            if isSearchPresented {
                // Instead of using the search text as a filter
                // we use it to actually find a specific user
                if viewModel.isSearching {
                    ProgressView()
                        .id(UUID())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let user = viewModel.searchedUser {
                    userRow(user)
                } else {
                    let text = searchText.isEmpty ? "Start typing to search" : "Not found"
                    let color = searchText.isEmpty ? Color.gray : Color.red
                    Text(text)
                        .italic()
                        .font(.footnote)
                        .foregroundStyle(color)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
            } else {
                ForEach(viewModel.users, id: \.id) { user in
                    userRow(user)
                }
                
                switch viewModel.state {
                case .complete:
                    EmptyView()
                case .loading, .hasMore:
                    ProgressView()
                        .id(UUID())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            if viewModel.state == .hasMore {
                                Task {
                                    await viewModel.fetchMore()
                                }
                            }
                        }
                case .error:
                    Text("An error occured (Tap to retry)")
                        .frame(maxWidth: .infinity)
                        .font(.callout)
                        .foregroundStyle(Color.red)
                        .onTapGesture {
                            Task {
                                await viewModel.fetchMore()
                            }
                        }
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Github Users")
        .animation(.default, value: UUID())
        
        .searchable(text: $searchText, isPresented: $isSearchPresented)
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .onChange(of: searchText) { _, newValue in
            viewModel.search(searchText: newValue)
        }

    }
    
    @ViewBuilder
    func userRow(_ user: GithubUser) -> some View {
        let viewModel = UserProfileViewModel(user: user, apiClient: dependencyGraph.apiClient)
        NavigationLink(destination: UserProfileView(viewModel: viewModel)) {
            HStack(alignment: .center, spacing: 12) {
                // ・User's avatar image
                KFImage.url(user.avatarUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .border(Color.gray, width: 1)
                
                // ・Username
                Text("\(user.login)")
                    .font(.headline)
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct UsersListView_Previews: PreviewProvider {
    
    // An API Client implementation that throws an error every other fetch
    class MockApiClient: ApiClient {
        
        enum MockError: Error {
            case unknown
        }
        
        // Whether the calls should fail on the furst run
        private let failOnFirst: Bool
        private let allUsers: [GithubUser] =
            Array(1...100).map { id in
                GithubUser(
                    id: Int64(id),
                    login: "user\(id)",
                    avatarUrl: URL(string: "https://httpbin.org/image/png")!
                )
            }
        
        private var runCount: Int = 0
        private var didSucceedLast: Bool = false
        
        init(failOnFirst: Bool) {
            self.failOnFirst = failOnFirst
        }
        
        func getUsers(since: Int64, perPage: Int) async throws -> [GithubUser] {
            runCount += 1
            if didSucceedLast || (failOnFirst && runCount == 1) {
                didSucceedLast = false
                throw MockError.unknown
            }
            
            didSucceedLast = true
            let users = allUsers.filter { $0.id > since }
            if users.count > perPage {
                return Array(users[0...perPage])
            } else {
                return users
            }
        }
        
        func getRepositories(login: String) async throws -> [GithubRepository] {
            throw MockError.unknown
        }
        
        func getUserInfo(login: String) async throws -> GithubUserInfo {
            if login == "test" {
                return GithubUserInfo(
                    id: Int64(0),
                    login: "test",
                    avatarUrl: URL(string: "https://httpbin.org/image/png")!,
                    name: "Test User",
                    followers: 0,
                    following: 0
                )
            } else {
                throw MockError.unknown
            }
        }
    }
    
    @ViewBuilder
    static func create(failOnFirst: Bool, colorScheme: ColorScheme) -> some View {
        let apiClient = MockApiClient(failOnFirst: failOnFirst)
        NavigationStack {
            UsersListView(
                viewModel: UsersListViewModel(apiClient: apiClient)
            )
        }
        .preferredColorScheme(colorScheme)
        .environmentObject(DependencyGraph(apiClient: apiClient))
        .previewDisplayName("failOnFirst:\(failOnFirst); colorScheme:\(colorScheme)")
    }
    
    static var previews: some View {
        create(failOnFirst: false, colorScheme: .light)
        create(failOnFirst: false, colorScheme: .dark)
        create(failOnFirst: true, colorScheme: .light)
        create(failOnFirst: true, colorScheme: .dark)
    }
}
