//
//  UserProfileView.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Kingfisher
import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State var isAlertPresented = false
    
    @State var searchText = ""
    @State var isSearchPresented = false
    
    private let githubColors = GithubColors()
    
    var body: some View {
        List {
            Section {
                let repositories = viewModel.repositories?.filter {
                    // Filter the list only if the search is presented
                    // and the user started typing
                    if isSearchPresented && !searchText.isEmpty {
                        $0.name.lowercased().contains(searchText.lowercased())
                    } else {
                        true
                    }
                }
                
                switch repositories {
                
                // Display the list of repositories if not empty
                case .some(let repositories) where !repositories.isEmpty:
                    ForEach(repositories, id: \.id) { repository in
                        NavigationLink(destination: WebView(url: repository.htmlUrl, navigationTitle: repository.name)) {
                            repositoryRow(repository)
                        }
                    }
                    
                // Show a note if the user does not have any repository
                case .some:
                    Text("No repositories found")
                        .italic()
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                    
                // Show a progress view when it is still pulling data
                case .none:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } header: {
                if isSearchPresented {
                    EmptyView()
                } else {
                    // Make the info section a header so we can make it freeze on top
                    HStack(alignment: .center, spacing: 16) {
                        //  ・Avatar image
                        KFImage.url(viewModel.user.avatarUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        
                        // Make a nice circle with a frame
                            .clipShape(Circle())
                            .overlay(content: {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1)
                            })
                        
                        if let userInfo = viewModel.userInfo {
                            VStack(alignment: .leading) {
                                // ・Full name
                                Text(userInfo.name)
                                    .font(.title2)
                                    .foregroundStyle(Color.primary)
                                    .padding(.bottom, 8)
                                
                                // ・Number of followers
                                Text("Followers: \(userInfo.followers)")
                                    .font(.footnote)
                                    .foregroundStyle(Color.primary)
                                
                                // ・Number of followings
                                Text("Following: \(userInfo.following)")
                                    .font(.footnote)
                                    .foregroundStyle(Color.primary)
                            }
                        } else {
                            // Show a progress view when it is still pulling data
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .padding([.top, .bottom], 16)
                }
            }
        }
        .listStyle(.inset)
        .onAppear {
            Task {
                do {
                    try await viewModel.fetch()
                } catch {
                    isAlertPresented = true
                }
            }
        }
        
        // ・Username
        .navigationTitle(viewModel.user.login)
        
        // Allow filtering repositories by name
        .searchable(text: $searchText, isPresented: $isSearchPresented)
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        
        // Show an alert that dismiss the screen when fetching fails
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text("Error"),
                message: Text("An unknown error occured"),
                dismissButton: .default(Text("OK"), action: {
                    dismiss()
                })
            )
        }
    }
    
    @ViewBuilder
    private func repositoryRow(_ repository: GithubRepository) -> some View {
        VStack(alignment: .leading) {
            // ・Repository name
            Text(repository.name)
                .bold()
                .underline()
                .font(.headline)
                .foregroundStyle(Color.blue)
            
            // ・Description (Displayed only when available)
            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .padding(.top, 2)
            }
            
            HStack(spacing: 4) {
                // ・Programming language used (Displayed only when available)
                if let language = repository.language {
                    if let hex = githubColors.hex(forKey: language),
                       let color = Color.from(hex: hex) {
                        Text("⚫︎")
                            .font(.footnote)
                            .foregroundStyle(color)
                    }
                    
                    Text(language)
                        .font(.footnote)
                        .padding(.trailing, 8)
                }
                
                // ・Number of stars (Displayed only when not 0)
                if repository.stargazersCount > 0 {
                     Text("★")
                         .font(.footnote)
                         .foregroundStyle(Color.yellow)
                    
                    Text("\(repository.stargazersCount)")
                        .font(.footnote)
                }
            }
            .padding(.top, 8)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    
    class MockApiClient: ApiClient {
        enum MockError: Error {
            case unknown
        }
        
        let hasRepos: Bool
        let failOnFetch: Bool
        
        init(hasRepos: Bool, failOnFetch: Bool) {
            self.hasRepos = hasRepos
            self.failOnFetch = failOnFetch
        }
        
        func getUsers(since: Int64, perPage: Int) async throws -> [GithubUser] {
            throw MockError.unknown
        }
        
        func getUserInfo(login: String) async throws -> GithubUserInfo {
            guard !failOnFetch else {
                throw MockError.unknown
            }
            
            return GithubUserInfo(
                id: Int64(0),
                login: "test",
                avatarUrl: URL(string: "https://httpbin.org/image/png")!,
                name: "Github User",
                followers: 10,
                following: 10
            )
        }
        
        func getRepositories(login: String) async throws -> [GithubRepository] {
            guard !failOnFetch else {
                throw MockError.unknown
            }
            
            return hasRepos ?
                [
                    GithubRepository(
                        id: 0,
                        name: "nodescription",
                        description: nil,
                        fork: false,
                        language: nil,
                        stargazersCount: 0,
                        htmlUrl: URL(string: "https://www.google.com")!
                    ),
                    GithubRepository(
                        id: 1,
                        name: "repository1",
                        description: "language:nil stars:40",
                        fork: false,
                        language: nil,
                        stargazersCount: 40,
                        htmlUrl: URL(string: "https://www.google.com")!
                    ),
                    GithubRepository(
                        id: 2,
                        name: "repository2",
                        description: "language:Swift stars:0",
                        fork: false,
                        language: "Swift",
                        stargazersCount: 0,
                        htmlUrl: URL(string: "https://www.google.com")!
                    ),
                    GithubRepository(
                        id: 3,
                        name: "repository3",
                        description: "language:Swift stars:40",
                        fork: false,
                        language: "kotlin",
                        stargazersCount: 40,
                        htmlUrl: URL(string: "https://www.google.com")!
                    ),
                    GithubRepository(
                        id: 4,
                        name: "repository4 (FORK)",
                        description: "language:Swift stars:40",
                        fork: true,
                        language: "Swift",
                        stargazersCount: 40,
                        htmlUrl: URL(string: "https://www.google.com")!
                    )
                ] : []
        }
    }
    
    @ViewBuilder
    static func create(
        hasRepos: Bool,
        failOnFetch: Bool,
        colorScheme: ColorScheme
    ) -> some View {
        let user = GithubUser(
            id: 0,
            login: "githubuser",
            avatarUrl: URL(string: "https://httpbin.org/image/png")!
        )
        
        let viewModel = UserProfileViewModel(
            user: user,
            apiClient: MockApiClient(hasRepos: hasRepos, failOnFetch: failOnFetch)
        )
        NavigationStack {
            UserProfileView(viewModel: viewModel)
        }
        .preferredColorScheme(colorScheme)
        .previewDisplayName("hasRepos: \(hasRepos);failOnFetch:\(failOnFetch);colorScheme:\(colorScheme)")
    }
    
    static var previews: some View {
        create(hasRepos: false, failOnFetch: false, colorScheme: .light)
        create(hasRepos: false, failOnFetch: false, colorScheme: .dark)
        create(hasRepos: true, failOnFetch: false, colorScheme: .light)
        create(hasRepos: true, failOnFetch: false, colorScheme: .dark)
        create(hasRepos: true, failOnFetch: true, colorScheme: .light)
        create(hasRepos: true, failOnFetch: true, colorScheme: .dark)
    }
}
