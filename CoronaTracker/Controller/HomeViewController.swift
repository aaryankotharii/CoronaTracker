//
//  HomeViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchbar: UISearchBar!
    let cellIdentifier = "cell"
    
    var moc : NSManagedObjectContext!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Country>!
    
    var searchPredicate = NSPredicate()
    
    var search = UISearchController(searchResultsController: nil)
    
    var rootView = CountryDetailView(hello: "lol")
    
    override func viewDidLoad() {
        
   //     self.navigationItem.searchController = search

        //search.delegate = self
       // search.searchBar.delegate = self
                
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        moc = appDelegate.persistentContainer.viewContext
        
        let sort = NSSortDescriptor(key: "name", ascending: true)        
        setupFetchedResultsController(sort: sort)    /// Setup fetchedResultsController
        //print(fetchedResultsController.fetchedObjects)
        if fetchedResultsController.fetchedObjects?.count == 0{

        CoronaClient.getSummary(completion: handleDownload(summary:error:))
        } else {
            CoronaClient.getSummary(completion: handleUpdate(summary:error:))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // tableView.tableHeaderView = search.searchBar
    }
    
    @IBSegueAction func goToCountryData(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: rootView)
    }
    
    
    func handleDownload(summary:Summary? ,error:Error?){
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
                        updateCountry(country)
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
    countryToSave.slug = country.Slug
    countryToSave.date = Date()
    countryToSave.newtotal = Int32(country.NewConfirmed)
    countryToSave.newdeaths = Int32(country.NewDeaths)
    countryToSave.newrecoveries = Int32(country.NewRecovered)
    do{
        try moc.save()
    } catch {
        print(error.localizedDescription)
    }
}
    
    func objectToStruct(_ country : Country)->Countries{
        let slug = country.slug!
        let newtotal = Int(country.newtotal)
        let newdeaths = Int(country.newdeaths)
        let newrecoveries = Int(country.newrecoveries)
        
        let name = country.name
        let deaths = Int(country.deaths)
        let total = Int(country.total)
        let recoveries = Int(country.recoveries)
        let countrycode = country.countrycode
        let date = country.date
        
        let countryStruct = Countries(Country: name!, CountryCode: countrycode!, Slug: slug, NewConfirmed: newtotal, TotalConfirmed: total, NewDeaths: newdeaths, TotalDeaths: deaths, NewRecovered: newrecoveries, TotalRecovered: recoveries, Date: "\(String(describing: date))")
        
        return countryStruct
    }

func updateCountry(_ country: Countries){
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

    
    //TODO new fetch request wih=thout predicate
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
        
        cell.name = name ?? ""
        
        cell.setupLabels()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
        let country = fetchCountry(cell.name ?? "india")
        
        let worldData = objectToStruct(country!)
        
        self.rootView = CountryDetailView(worldData: worldData, hello: cell.countryNameLabel.text ?? "no",slug: country!.slug ?? "india")

        performSegue(withIdentifier: "countryData", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
}

extension HomeViewController : NSFetchedResultsControllerDelegate {
    
    //MARK:- Set FetchedResultsViewController
    func setupFetchedResultsController(sort : NSSortDescriptor,predicate:NSPredicate? = nil) {
        let fetchRequest : NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        if let predicate = predicate {
         fetchRequest.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
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
            //print("update")
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
}

extension HomeViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Add your search logic here
        var predicate: NSPredicate? = nil

        fetchedResultsController = nil
        if searchBar.text?.count != 0 {
            predicate = NSPredicate(format: "name contains[c] %@", searchBar.text!)
        }
        let sort = NSSortDescriptor(key: "name", ascending: true)
        setupFetchedResultsController(sort: sort, predicate: predicate)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let sort = NSSortDescriptor(key: "name", ascending: true)
        setupFetchedResultsController(sort: sort)
        tableView.reloadData()
    }
    
    
    func updateSearchResults(_ text : String) {
        var predicate: NSPredicate?
        
        let sort = NSSortDescriptor(key: "name", ascending: true)
        let resultPredicate = NSPredicate(format: "name contains[c] %@", "in")
        
        setupFetchedResultsController(sort: sort,predicate: resultPredicate)    /// Setup fetchedResultsController
}

}
//func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//    let topIndex = IndexPath(row: 0, section: 0)
//    if let navController = viewController as? UINavigationController,
//        navController.childViewControllers.count > 0 {
//        let childController = navController.childViewControllers[0]
//        if let vc = childController as? AlbumsTableViewController {
//            vc.tableView.scrollToRow(at: topIndex, at: .top, animated: true)
//        } else if let vc = childController as? ArtistsTableViewController {
//            vc.tableView.scrollToRow(at: topIndex, at: .top, animated: true)
//        }
//    }
//}
//
