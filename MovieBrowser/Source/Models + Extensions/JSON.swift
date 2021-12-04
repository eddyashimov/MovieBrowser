//
//  JSON.swift
//  MovieBrowser
//
//  Created by Edil Ashimov on 12/3/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation

struct JSON {
    
    //MARK: - Search
    struct Search: Codable {
        let results: [Movie]?
        
        private enum CodingKeys: String, CodingKey {
            case results = "results"
        }
        
        struct Movie: Codable {
            let title: String
            let id: Int
            let releaseDate: String
            let voteAverage: Double

            private enum CodingKeys: String, CodingKey {
                case title = "title"
                case id = "id"
                case releaseDate = "release_date"
                case voteAverage = "vote_average"

            }
        }
    }

    //MARK: - Movie
    struct Movie: Codable {
        let id: Int
        let releaseDate: String
        let posterPath: String?
        let title: String
        let overview: String?

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case releaseDate = "release_date"
            case posterPath = "poster_path"
            case title = "title"
            case overview = "overview"
        }
    }
}
