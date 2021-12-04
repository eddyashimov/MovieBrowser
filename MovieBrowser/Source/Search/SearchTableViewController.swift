//
//  SearchViewController.swift
//  SampleApp
//
//  Created by Struzinski, Mark on 2/19/21.
//  Copyright © 2021 Lowe's Home Improvement. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    private let networkService = Network()
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
    private let reachable = Reachability()!
    private var movies = [JSON.Search.Movie]()
    private let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchText: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        registerNibs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setReachabilityNotifier()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Movies Search"
    }
    
    private func registerNibs() {
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - Network Listener | Reachability
    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            self.presentAlert(message: "Please connect to internet to search", title: "No Connection")
        }
    }
    
    private func setReachabilityNotifier () {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachable)
        do {
            try reachable.startNotifier()
        }
        catch {
            print("could not start reachability notifier")
        }
    }
    
    private func checkReachable() {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
        
        if (isNetworkReachable(with: flags)){
            if flags.contains(.isWWAN) {
                return
            }
        }
        else if (!isNetworkReachable(with: flags)) {
            self.presentAlert(message:"Please connect to internet to search", title: "No Connection")
            searchController.searchBar.endEditing(true)
            return
        }
    }
    
    // MARK: - Search Controller & Search Methods
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showInfoLabel(withText: "Begin your Movie Search")
        self.movies.removeAll()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        checkReachable()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        checkReachable()
    }
    
    func search(for movieName: String, page: Int, handler: @escaping ((Bool, Error?) -> Void)) {
        networkService.search(for: movieName, page: page) { (searchObject, error) in
            guard searchObject != nil && error == nil else {
                print(error?.localizedDescription ?? "Error")
                handler(false, error)
                return
            }
            
            if let searchResults = searchObject?.results,
               searchResults.count > 0 {
                self.movies = searchResults
                
                DispatchQueue.main.async {
                    self.tableView.backgroundView = UIView()
                    self.tableView.reloadData()
                }
            } else {
                
                DispatchQueue.main.async {
                    self.movies.removeAll()
                    self.showInfoLabel(withText: "No Matches Found")
                    self.tableView.reloadData()
                }
            }
            
            handler(true, nil)
        }
    }
    
    // MARK: - Helpers
    private func configureUI(){
        searchController.searchBar.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.black
        
        showInfoLabel(withText: "Begin your Movie Search")
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(hex: "4597FE")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        }
        else {
            navigationController?.navigationBar.backgroundColor = UIColor(hex: "4597FE")
        }
    }
    
    private func showInfoLabel(withText text: String) {
        let helpLabel = UILabel()
        helpLabel.backgroundColor = UIColor.white
        helpLabel.frame.size = CGSize.zero
        helpLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        helpLabel.textColor = UIColor.gray
        helpLabel.textAlignment = .center
        helpLabel.text = text
        helpLabel.sizeToFit()
        helpLabel.font = UIFont.systemFont(ofSize: 30)
        helpLabel.numberOfLines = 2
        tableView.backgroundView = helpLabel
    }
    
    // MARK: - Tableview Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? SearchTableViewCell {
            cell.configureCell(with: movies[indexPath.row])
            return cell
        }
        else{
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        performSegue(withIdentifier: "movieDetails", sender: movies[indexPath.row].id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              identifier == "movieDetails",
              let viewController = segue.destination as? MovieDetailViewController,
              let movieID = sender else { return }
        viewController.selectedMovieId = String(describing: movieID)
    }
    
}

// MARK: - Search Methods
extension SearchTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text,
              searchTerm.count > 1 else { return }
        self.searchText = searchTerm
        
        search(for: searchTerm, page: 1) { (done, error) in
            DispatchQueue.main.async {}
            guard !done else { return }
            print(error?.localizedDescription ?? "Error")
        }
    }
    
}



