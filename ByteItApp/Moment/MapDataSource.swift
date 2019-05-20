//
//  MapDataSource.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/14/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import MapKit

protocol MapDataSourceDelegate: class{
    func refreshData()
    func giveTest(s: String)
}


class MapDataSource:NSObject{
    
    var search:MKLocalSearch? =  nil
    
    var searchCompleter = MKLocalSearchCompleter()
    
    var places = [MKLocalSearchCompletion]()
    
    var selectedPlace: MKMapItem? = nil
    
    var testString: String = "test"
    
    weak var delegate:MapDataSourceDelegate?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
    }
    
    func locationCount() -> Int {
        return places.count
    }
    
    func locationAt(index:IndexPath) -> MKLocalSearchCompletion{
        return places[index.row]
    }
}

extension MapDataSource:CLLocationManagerDelegate{
    
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
extension MapDataSource:UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = locationCount()
        
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let item = locationAt(index: indexPath)
        
        cell.textLabel?.text = item.title
        
        cell.detailTextLabel?.text = item.subtitle
        
        return cell
    }
    
}

extension MapDataSource:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hola 1??")
        let item = locationAt(index: indexPath)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = item.subtitle
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            print("hola 2??")
            guard let response = response else {return}
            guard let item = response.mapItems.first else {return}
            self.selectedPlace = item
            self.testString = "Barcelona"
            self.delegate?.giveTest(s: self.testString)
//            self.delegate?.setPlace(place: item)
            //            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
}


extension MapDataSource:MKLocalSearchCompleterDelegate{
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        places = completer.results
        
        delegate?.refreshData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        
    }
}


extension MapDataSource:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}
