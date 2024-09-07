//
//  GithubColors.swift
//  GhUserCollection
//
//  Created by Paulus Armada on 2024/09/07.
//

import Foundation

// Parser for colors.json from https://github.com/ozh/github-colors
class GithubColors {
    private let map: [String: String]
    
    init(bundle: Bundle = Bundle.main) {
        if let url = bundle.url(forResource: "colors", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONDecoder().decode([String: [String: String?]].self, from: data) {
            var map = json.compactMapValues { $0["color"] ?? nil }
            
            // Convert the keys to lower case afterwards for easy access
            map.keys.forEach { key in
                map[key.lowercased()] = map.removeValue(forKey: key)
            }
            self.map = map
        } else {
            self.map = [:]
        }
    }
    
    func hex(forKey key: String) -> String? {
        map[key.lowercased()]
    }
}
