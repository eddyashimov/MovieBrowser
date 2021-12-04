//
//  Extensions.swift
//  MovieBrowser
//
//  Created by Edil Ashimov on 12/3/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

extension URLRequest {
    
    struct httpMethod {
        static let GET: String = "GET"
    }
    
    init(withUrl url: URL, httpBody: Data?, httpHeaderFields: [String: String], httpMethod: String, networkServiceType: NetworkServiceType = .default, cachePolicy: NSURLRequest.CachePolicy = .reloadRevalidatingCacheData) {
        self.init(url: url)
        
        self.networkServiceType = networkServiceType
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.cachePolicy = cachePolicy
        
        for (key, value) in httpHeaderFields {
            self.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
}

extension UIViewController {
    func presentAlert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        DispatchQueue.main.async  {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
