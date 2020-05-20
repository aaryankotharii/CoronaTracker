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
        
        setupFetchedResultsController()
        loadMap()
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    
    @IBAction func tappedOnMap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: mapView)
            let coordinate = self.mapView.convert(tapLocation, toCoordinateFrom: self.mapView)
        print(coordinate)
    }
    
    func addOverlay(radius:CLLocationDistance,coord:CLLocationCoordinate2D){
                let center = coord
        let circle = MKCircle(center: center, radius: radius)
                mapView.addOverlay(circle)
            }
    

    
    //MARK:-  ----------    ADD PIN FUNCTIONS   ----------
    
    //MARK: Add annotation to mapView
    func AddAnnotationToMap(_ fromCoordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoordinate
        mapView.addAnnotation(annotation)
    }
    

    
    
    //MARK: get pin from annotation
    func fetchPin(_ coordinate: CLLocationCoordinate2D) -> Country?{
        if let countries = fetchedResultsController.fetchedObjects{
            let country = countries.filter{ $0.coordinate == coordinate}
            return country.first
        }
        return nil
    }
    
    func calculateRadius(_ numberOfCases : Int)->Int{
        switch numberOfCases {
        case _ where numberOfCases < 1000:
                   return 30000
        case _ where numberOfCases < 20000:
            return 80000
        case _ where numberOfCases > 1500000:
            return 1200000
        case  _ where numberOfCases > 150000:
           return numberOfCases * 2
        default:
            return numberOfCases*4
        }
    }
    
    // ADD Annotations from coredata pins
    func loadMap(){
            if let points = fetchedResultsController.fetchedObjects{
                for point in points {
                    let coordinate = point.coordinate
                    let radius = calculateRadius(Int(point.total))
                    addOverlay(radius: CLLocationDistance(radius), coord: coordinate)
                }
            }
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
        let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
            circleRenderer.strokeColor = UIColor.blue
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
        return MKOverlayRenderer(overlay: overlay)
    }
}

//MARK:-  FetchedResultsController Delegate Methods + Private Methods
extension MapViewController : NSFetchedResultsControllerDelegate {
    
    //MARK:- Set FetchedResultsViewController
    func setupFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let point = anObject as? Country else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        switch type {
        case .insert:
            AddAnnotationToMap(point.coordinate)
        case .delete:
            print("Pin Delete successful")
        default:
            break
        }
    }
}

//MARK:- Returns coordinate of Pin from attributes
extension Country: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        let latDegrees = CLLocationDegrees(lat)
        let longDegrees = CLLocationDegrees(long)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}

