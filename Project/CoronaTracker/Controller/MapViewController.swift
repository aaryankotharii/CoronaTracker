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
    
    //MARK: - Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var dataView: UIView!
    @IBOutlet var countryNameLabel: UILabel!
    @IBOutlet var newCasesLabel: UILabel!
    @IBOutlet var newRecoveredLabel: UILabel!
    @IBOutlet var newDeathsLabel: UILabel!
    @IBOutlet var newActiveLabel: UILabel!
    @IBOutlet var totalCasesLabel: UILabel!
    @IBOutlet var totalRecoveredLabel: UILabel!
    @IBOutlet var totalDeathsLabel: UILabel!
    @IBOutlet var totalActiveLabel: UILabel!
    
    
    /// Manages Object Context  to save data to Database
    var moc : NSManagedObjectContext!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Country>!
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Core Data Setup
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        moc = appDelegate.persistentContainer.viewContext
        setupFetchedResultsController()
        
        /// Map Setup
        mapView.delegate = self
        loadMap()
        
        /// DataView Setup
        dataView.isHidden = true
        setupDetailViewUI()
    }
    
    func setupDetailViewUI(){
        dataView.alpha = 0.86
        dataView.layer.cornerRadius = 22
        dataView.layer.shadowColor = #colorLiteral(red: 0.7215686275, green: 0.8784313725, blue: 0.9490196078, alpha: 1).cgColor
        dataView.layer.shadowOpacity = 1.0
        dataView.layer.shadowOffset = CGSize(width: 0, height: 0)
        dataView.layer.shadowRadius = 5
        dataView.layer.shadowPath  = UIBezierPath(roundedRect: dataView.bounds, cornerRadius: 22).cgPath
    }
    
    func setupDataView(_ country : Country){
        let emoji = convertToEmoji(str: country.countrycode ?? "IN")
        countryNameLabel.text = emoji + " " + country.name!
        newCasesLabel.text = "\(country.newtotal)"
        newRecoveredLabel.text = "\(country.newrecoveries)"
        newDeathsLabel.text = "\(country.newdeaths)"
        newActiveLabel.text = "-"
        totalCasesLabel.text = "\(country.total)"
        totalRecoveredLabel.text = "\(country.recoveries)"
        totalDeathsLabel.text = "\(country.deaths)"
        let totalActive = country.total - country.recoveries - country.deaths
        totalActiveLabel.text = "\(totalActive)"
    }
        
    @IBAction func tappedOnMap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: mapView)
        let coordinate = self.mapView.convert(tapLocation, toCoordinateFrom: self.mapView)
        print(coordinate)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        fetchChountry(location) { code in
            if let code = code {
                let country = self.fetchCountryObject(code)
                self.setupDataView(country!)
                self.presentDataView()
                self.mapView.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func tappedOnDataView(_ sender: UITapGestureRecognizer) {
        dataView.isHidden = true
        self.mapView.isUserInteractionEnabled = true
    }
    
    func presentDataView(){
        self.dataView.isHidden  = false
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.4
        animation.timingFunction=CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = false
        animation.repeatCount = 1
        dataView.layer.add(animation, forKey:"abcd")
    }
    
    
    func fetchCountryObject(_ code : String)-> Country?{
        if let countries = fetchedResultsController.fetchedObjects{
            let country = countries.filter{ $0.countrycode == code}
            return country.first!
        }
        return nil
    }
    
    
    func fetchChountry(_ coordinate : CLLocation, completion: @escaping (String?)->()){
        CLGeocoder().reverseGeocodeLocation(coordinate) { (placemarks, error) in
            if let error = error{
                if error.localizedDescription == "The operation couldn’t be completed. (kCLErrorDomain error 2.)" {
                    self.networkErrorAlert(title: "Internet required to show country data")
                }
                completion(nil)
                return
            }
            if let placemarks = placemarks{
                let placemark = placemarks.first
                if let country = placemark?.isoCountryCode{
                    completion(country)
                }
            }
        }
    }
    
    /// ADD overlay to map
    func addOverlay(radius:CLLocationDistance,coord:CLLocationCoordinate2D){
        let center = coord
        let circle = MKCircle(center: center, radius: radius)
        mapView.addOverlay(circle)
    }
    
    //MARK: get pin from annotation
    func fetchPin(_ coordinate: CLLocationCoordinate2D) -> Country?{
        if let countries = fetchedResultsController.fetchedObjects{
            let country = countries.filter{ $0.coordinate == coordinate}
            return country.first
        }
        return nil
    }
    
    /// Calculates appropriate radius of circular overlays
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


//MARK:- MapView Delegate  Methods
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = #colorLiteral(red: 0.8, green: 0.4078431373, blue: 0.4901960784, alpha: 1).withAlphaComponent(0.35)
            circleRenderer.strokeColor = #colorLiteral(red: 0.8, green: 0.4078431373, blue: 0.4901960784, alpha: 1)
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
        }catch{
            fatalError(error.localizedDescription)
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
