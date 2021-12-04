//
//  Network.swift
//  SampleApp
//
//  Created by Struzinski, Mark - Mark on 9/17/20.
//  Copyright © 2020 Lowe's Home Improvement. All rights reserved.
//

import Foundation

class Network {
    
    private struct authParameters {
        struct Keys {
            static let key = "api_key"
        }
        
        static let apiKey = "5885c445eab51c7004916b9c0313e2d3"
    }
    
    static var shared: Network = {
        return Network()
    }()
    
    private func httpHeaderFields() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    private func request(url: String,
                         cachePolicy: URLRequest.CachePolicy = .reloadRevalidatingCacheData,
                         httpMethod: String,
                         httpHeaderFields: [String:String],
                         httpBody: Data?,
                         parameters: [URLQueryItem]?,
                         handler: @escaping (Data?, URLResponse?, Int?, Error?) -> Void) {
        
        guard var urlComponent = URLComponents(string: url) else { return }
        urlComponent.queryItems = parameters
        
        guard let _url = urlComponent.url else { return }
        let request: URLRequest = URLRequest(withUrl: _url,
                                             httpBody: nil,
                                             httpHeaderFields: httpHeaderFields,
                                             httpMethod: URLRequest.httpMethod.GET,
                                             cachePolicy: cachePolicy)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let httpResponsStatusCode = (response as? HTTPURLResponse)?.statusCode
            handler(data, response, httpResponsStatusCode, error)
            
        }.resume()
    }
    
}

extension Network {
    
    func search(for title: String, page: Int = 1, handler: @escaping(JSON.Search?, Error?) -> Void) {
        
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "query", value: title))
        queries.append(URLQueryItem(name: "page", value: String(page)))
        queries.append(URLQueryItem(name: authParameters.Keys.key, value: authParameters.apiKey))
        
        request(url: EndPoints.Search.path,
                httpMethod: URLRequest.httpMethod.GET,
                httpHeaderFields: httpHeaderFields(),
                httpBody: nil,
                parameters: queries) { data, response, status, error in
            
            guard let _data = data, status == 200 else { return }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(JSON.Search.self, from: _data)
                handler(result, nil)
            }
            catch let error {
                handler(nil, error)
            }
        }
    }
    
    func getMovie(with id: String, handler: @escaping(JSON.Movie?, Error?) -> Void) {
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: authParameters.Keys.key, value: authParameters.apiKey))
        
        request(url: EndPoints.Details.path + "\(id)?",
                httpMethod: URLRequest.httpMethod.GET,
                httpHeaderFields: httpHeaderFields(),
                httpBody: nil, parameters: queries) { data, response, status, error in
            
            guard let _data = data, status == 200 else { return }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(JSON.Movie.self, from: _data)
                handler(result, nil)
            }
            catch let error {
                handler(nil, error)
            }
        }
    }
    
    func getImage(with path: String, handler: @escaping(Data?, Error?) -> Void) {
        guard let url = URL(string: EndPoints.Poster.url + path) else { return }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.httpMethod = URLRequest.httpMethod.GET
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _data = data {
                handler(_data, nil)
            }
            else {
                handler(nil, error)
            }
            
        }.resume()
    }
    
}

