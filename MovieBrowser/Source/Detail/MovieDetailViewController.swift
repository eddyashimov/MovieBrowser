//
//  MovieDetailViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/26/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit

import UIKit

class MovieDetailViewController: UIViewController {
    private let networkService = Network()
    
    @IBOutlet private var movieImageView: UIImageView!
    @IBOutlet private var movieDescriptionTextView: UITextView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var releaseDate: UILabel!
    
    var selectedMovieId: String?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        if let id = selectedMovieId {
            loadMovie(withID: id)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        movieDescriptionTextView.isEditable = false
        movieDescriptionTextView.backgroundColor = UIColor.clear
        movieDescriptionTextView.isUserInteractionEnabled = false
        navigationItem.titleView?.tintColor = .white
    }
    
    private func showHelpLabel(withText text: String) {
        DispatchQueue.main.async {
            let helpLabel = UILabel()
            helpLabel.frame.size = CGSize.zero
            helpLabel.font = UIFont.preferredFont(forTextStyle: .callout)
            helpLabel.textColor = UIColor.lightGray
            helpLabel.textAlignment = .center
            helpLabel.text = text
            helpLabel.numberOfLines = 0
            helpLabel.lineBreakMode = .byWordWrapping
            helpLabel.sizeToFit()
        }
    }
    
    private func loadMovie(withID id: String) {
        networkService.getMovie(with: id) { [weak self] (movieObject, error) in
            if let movie = movieObject, error == nil {
                self?.setMovieInfo(with: movie)
            }
            else {
                self?.showHelpLabel(withText: error?.localizedDescription ?? "Error")
                print(error?.localizedDescription ?? "Error")
            }
        }
    }
    
    private func setMovieInfo(with movie: JSON.Movie) {
        DispatchQueue.main.async {
            self.setPoster(with: movie)
            self.titleLabel.text = movie.title
            self.releaseDate.text = "Release Date : \(movie.releaseDate)"
            self.movieDescriptionTextView.text = movie.overview
        }
    }
    
    private func setPoster(with movie: JSON.Movie) {
        guard let posterPath = movie.posterPath else { return }
        self.networkService.getImage(with: posterPath, handler: { [weak self] (data, error) in
            guard let _data = data else { return }
            DispatchQueue.main.async {
                self?.movieImageView.image = UIImage(data: _data)
            }
        })
    }
    
}
