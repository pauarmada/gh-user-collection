//
//  DependencyGraph.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/06.
//

import Foundation

class DependencyGraph: ObservableObject {
    @Published var apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    static var `default` = DependencyGraph(apiClient: GithubClient())
}
