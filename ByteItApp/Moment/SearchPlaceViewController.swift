//
//  SearchPlaceViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/14/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class SearchPlaceViewController: UITableViewController {

    private var searchController:UISearchController = UISearchController()
    private let manager = CLLocationManager()
    let dataSource = MapDataSource()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController =  UISearchController(searchResultsController:nil)
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController.searchBar.delegate = dataSource
        searchController.isActive = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        manager.delegate = dataSource
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension SearchPlaceViewController:MapDataSourceDelegate {
    func refreshData() {
        self.tableView.reloadData()
    }

    func giveTest(s: String) {
        print(s)

    }
}



