//
//  EndPoints.swift
//  MovieBrowser
//
//  Created by Edil Ashimov on 12/3/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import Foundation

enum EndPoints {
    case Search
    case Details
    case Poster
}

extension EndPoints {
    var url: String {
        return "https://image.tmdb.org/t/p/original"
    }
    
    var path:String {
        let baseURL = "https://api.themoviedb.org/3/"
        
        switch(self) {
        case .Search:
            return "\(baseURL)search/movie?"
        case .Details:
            return "\(baseURL)movie/"
        case .Poster:
            return url
        }
    }
    
}
