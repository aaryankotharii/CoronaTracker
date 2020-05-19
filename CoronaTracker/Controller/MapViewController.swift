//
//  MapViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 19/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var moc : NSManagedObjectContext!
    
    
    
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Country>!
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        moc = appDelegate.persistentContainer.viewContext
        
        super.viewDidLoad()
    }
}
