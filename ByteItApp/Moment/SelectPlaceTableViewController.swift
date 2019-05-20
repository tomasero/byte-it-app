//
//  SelectPlaceTableViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/15/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import MapKit

class SelectPlaceTableViewController: UITableViewController {
    
    var search:MKLocalSearch? =  nil
    var searchCompleter = MKLocalSearchCompleter()
    var places = [MKLocalSearchCompletion]()
    var selectedPlace: MKMapItem? = nil
    var placeName: String = ""
    var testString: String = "test"
    var momentVC: MomentViewController?
    var delegate: isAbleToReceivePlace?
    
    func locationCount() -> Int {
        return places.count
    }
    
    func locationAt(index:IndexPath) -> MKLocalSearchCompletion{
        return places[index.row]
    }
    
    @IBAction func cancelSelectPlace(_ sender: UIBarButtonItem) {
        print("cancelSelectPlace")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneSelectPlace(_ sender: Any) {
        print("doneSelectPlace")
        print(selectedPlace)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationSelected"), object: nil)
        if let selectedPlace = selectedPlace {
            self.delegate?.pass(data:selectedPlace)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("view will dissapear")
        
    }
    
    var searchController:CustomSearchController = CustomSearchController()
    private let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.tableView.allowsSelection = true
        
        momentVC = self.presentingViewController?.presentingViewController as? MomentViewController
        
        searchCompleter.delegate = self
        
        
        searchController = CustomSearchController(searchResultsController:nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
//        searchController.searchBar.text = selectedPlace?.name
        searchController.searchBar.text = self.placeName
        searchController.searchBar.setShowsCancelButton(false, animated: false)
        searchController.searchBar.delegate = self
//        searchController.searchBar.canc
        searchController.isActive = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.dataSource = self
        tableView.delegate = self
        manager.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = locationCount()
        return count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let item = locationAt(index: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        return cell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchController.searchBar.showsCancelButton = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        let item = locationAt(index: indexPath)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = item.subtitle
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            print("search start")
            guard let response = response else {return}
            guard let item = response.mapItems.first else {return}
            self.selectedPlace = item
            print(item)
            print("bfr")
//            print(self.momentVC?.location!)
//            self.momentVC?.location = item
//            self.delegate?.giveTest(s: self.testString)
            //            self.delegate?.setPlace(place: item)
            //            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
        self.searchController.isActive = false
        self.searchController.dismiss(animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectPlaceTableViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch  status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {return}
        
        searchCompleter.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
        
        
    }
}

extension SelectPlaceTableViewController:MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        places = completer.results
        print("cometelerdidupdateresutls")
        self.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }
}

extension SelectPlaceTableViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

class CustomSearchController: UISearchController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.showsCancelButton = false
    }
}
