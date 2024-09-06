//
//  ContentView.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dependencyGraph = DependencyGraph.default
    
    var body: some View {
        let viewModel = UsersListViewModel(
            apiClient: dependencyGraph.apiClient
        )
        NavigationStack {
            UsersListView(viewModel: viewModel)
        }
        .environmentObject(dependencyGraph)
    }
}

#Preview {
    ContentView()
}
