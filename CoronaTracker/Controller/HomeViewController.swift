//
//  HomeViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let cellIdentifier = "cell"
    
    var moc : NSManagedObjectContext!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Country>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        moc = appDelegate.persistentContainer.viewContext
        setupFetchedResultsController()    /// Setup fetchedResultsController
        print(fetchedResultsController.fetchedObjects)
        if fetchedResultsController.fetchedObjects?.count == 0{

        CoronaClient.getSummary(completion: handleSummary(summary:error:))
        } else {
            CoronaClient.getSummary(completion: handleUpdate(summary:error:))
        }
    }
    
    func handleSummary(summary:Summary? ,error:Error?){
        if let summary = summary {
                for country in summary.Countries{
                    addCountry(country)
            }
        } else {
        return
    
    print(error!.localizedDescription,"errr",error.debugDescription)
}
    }
    
        func handleUpdate(summary:Summary? ,error:Error?){
            if let summary = summary {
                                 for country in summary.Countries{
                        
                        upDate(country)
                    }
            } else {
            return
        
        print(error!.localizedDescription,"errr",error.debugDescription)
    }
        }
    
    
    

             

func addCountry(_ country: Countries){
    let countryToSave = Country(context: moc)
    countryToSave.name = country.Country
    countryToSave.deaths = Int32(country.TotalDeaths)
    countryToSave.total = Int32(country.TotalConfirmed)
    countryToSave.recoveries = Int32(country.TotalRecovered)
    countryToSave.countrycode = country.CountryCode
    do{
        try moc.save()
    } catch {
        print(error.localizedDescription)
    }
}

func upDate(_ country: Countries){
    let CountryToUpdate = fetchCountry(country.Country)
    CountryToUpdate?.deaths = Int32(country.TotalDeaths)
    CountryToUpdate?.total = Int32(country.TotalConfirmed)
    CountryToUpdate?.recoveries = Int32(country.TotalRecovered)
    CountryToUpdate?.countrycode = country.CountryCode
    do{
        try moc.save()
    } catch {
        print(error.localizedDescription)
    }
}

func fetchCountry(_ name : String)-> Country?{
    if let countries = fetchedResultsController.fetchedObjects{
        let country = countries.filter{ $0.name == name}
        return country.first!
    }
    return nil
}

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HomeTableViewCell
        
        let country = fetchedResultsController.object(at: indexPath)
        
        let name = country.name
        
        let emoji = convertToEmoji(str: country.countrycode ?? "") //TODO add default code
        
        cell.countryNameLabel.text = "\(emoji) \(name ?? "")"
        
        cell.total = Int(country.total)
        cell.deaths = Int(country.deaths)
        cell.recovered = Int(country.recoveries)
        
        cell.setupLabels()
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
}

extension HomeViewController : NSFetchedResultsControllerDelegate {
    
    //MARK:- Set FetchedResultsViewController
    func setupFetchedResultsController() {
        let fetchRequest : NSFetchRequest<Country> = Country.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        let resultPredicate = NSPredicate(format: "name contains[c] %@", "f")
        //  fetchRequest.predicate = resultPredicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Country")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            print("update")
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
}

