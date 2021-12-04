//
//  SearchTableViewCell.swift
//  MovieBrowser
//
//  Created by Edil Ashimov on 12/3/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var movieTitleLabel: UILabel!
    @IBOutlet private weak var movieDateLabel: UILabel!
    @IBOutlet private weak var movieRatingLabel: UILabel!
    private let networkService = Network()

    // MARK: - Lifecycle
    override init(style: SearchTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "movieCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helpers
    func configureCell(with info: JSON.Search.Movie){
        movieTitleLabel.text = info.title
        movieDateLabel.text = info.releaseDate
        movieRatingLabel.text = "\(info.voteAverage)"
    }

}
