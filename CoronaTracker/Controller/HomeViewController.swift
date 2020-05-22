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
    
    
    @IBOutlet var globeButton: UIButton!
    
    //  @IBOutlet var searchbar: UISearchBar!
    let cellIdentifier = "cell"
    
    var moc : NSManagedObjectContext!
    
    /// Fetched Results controller to fetch data from Database
    var fetchedResultsController : NSFetchedResultsController<Country>!
    
    var searchPredicate = NSPredicate()
    
    /// Search controller to help us with filtering items in the table view.
    var searchController: UISearchController!
    
    /// Search results table view.
    private var resultsTableController: ResultsTableViewController!
    
    var sort =  NSSortDescriptor(key: "name", ascending: true)
    
    var search = UISearchController(searchResultsController: nil)
    
    var countrycases : [countrycase] = []
    
    var countryRootView = CountryDetailView(hello: "lol")
    
    override func viewDidLoad() {
        
        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableViewController
        // This view controller is interested in table view row selections.
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
        searchController.searchBar.delegate = self
        
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        moc = appDelegate.persistentContainer.viewContext
        
        let sort = NSSortDescriptor(key: "name", ascending: true)        
        setupFetchedResultsController(sort: sort)    /// Setup fetchedResultsController
        if fetchedResultsController.fetchedObjects?.count == 0{
            
            CoronaClient.getSummary(completion: handleDownload(summary:error:))
        } else {
            CoronaClient.getSummary(completion: handleUpdate(summary:error:))
        }
        resultsTableController.filteredProducts  = fetchedResultsController.fetchedObjects!
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.searchController = searchController
    }
    
    @IBSegueAction func goToCountryData(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: countryRootView)
    }
    
    @IBSegueAction func goToGlobalData(_ coder: NSCoder) -> UIViewController? {
        let globalRootView = GlobeView(cases: countrycases)
        return UIHostingController(coder: coder, rootView: globalRootView .environment(\.managedObjectContext, self.moc))
    }
    @IBAction func reloadClicked(_ sender: Any) {
        CoronaClient.getSummary(completion: handleUpdate(summary:error:))
    }
    
    @IBAction func sortClicked(_ sender: UIButton) {
        if sender.tag == 0{
            presentAlert(false)
        } else {
            presentAlert(true)
        }
    }
    
    enum SortType{
        case name(state : Bool)
        case death
        case recovered
        case total
        case state(state : Bool)
        
        var stringValue : String {
            switch self {
            case .death:
                return "Deaths"
            case .name(state: let state):
                return state ? "Name (Z - A)" : "Name (A - Z)"
            case .recovered:
                return "Recovered "
            case .total:
                return  "Total"
            case .state(let state):
                return state ? "Lowest First" : "Highest First"
            }
        }
    }
    
    func presentAlert(_ state : Bool){
        let alert = UIAlertController(title: "Sort", message: SortType.state(state: state).stringValue, preferredStyle: .actionSheet)
        let nameSort = UIAlertAction(title: SortType.name(state: state).stringValue, style: .default) { (action) in
            self.sort = NSSortDescriptor(key: "name", ascending: state)
            self.setupFetchedResultsController(sort: self.sort)
        }
        let totalSort = UIAlertAction(title: SortType.total.stringValue, style: .default) { (action) in
            self.sort = NSSortDescriptor(key: "total", ascending: state)
            self.setupFetchedResultsController(sort: self.sort)
        }
        
        let deathSort = UIAlertAction(title: SortType.death.stringValue, style: .default) { (action) in
            self.sort = NSSortDescriptor(key: "deaths", ascending: state)
            self.setupFetchedResultsController(sort: self.sort)
        }
        
        let recovered = UIAlertAction(title: SortType.recovered.stringValue, style: .default) { (action) in
            self.sort = NSSortDescriptor(key: "recoveries", ascending: state)
            self.setupFetchedResultsController(sort: self.sort)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alert.addAction(nameSort)
        alert.addAction(totalSort)
        alert.addAction(deathSort)
        alert.addAction(recovered)
        alert.addAction(cancel)
        
        self.present(alert, animated :true)
    }
    
    
    func handleDownload(summary:Summary? ,error:Error?){
        countrycases.removeAll()
        if let summary = summary {
            for country in summary.Countries{
                addCountry(country)
                objectToGlobalStruct(country)
            }
            addGlobal(summary.Global)
        } else {
            return
                
                print(error!.localizedDescription,"errr",error.debugDescription)
        }
    }
    
    func handleUpdate(summary:Summary? ,error:Error?){
        countrycases.removeAll()
        if let summary = summary {
            for country in summary.Countries{
                updateCountry(country)
                objectToGlobalStruct(country)
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
        
        let coord = fetchCoord(country.CountryCode)
        countryToSave.lat = coord.first ?? 0
        countryToSave.long = coord.last ?? 0
        
        do{
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    func addGlobal(_ global : GlobalData){
        let globalToSave = Global(context: moc)
        globalToSave.newconfirmed = Int32(global.NewConfirmed)
        globalToSave.newdeaths = Int32(global.NewDeaths)
        globalToSave.newrecovered = Int32(global.NewRecovered)
        globalToSave.totaldeaths = Int32(global.TotalDeaths)
        globalToSave.totalconfirmed = Int32(global.TotalConfirmed)
        globalToSave.totalrecovered = Int32(global.TotalRecovered)
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
    
    //TODO maybe fetch again
    func objectToGlobalStruct(_ country : Countries){
        let name = country.Country
        let emoji = convertToEmoji(str: country.CountryCode)
        let total = country.TotalConfirmed
        let data = countrycase(name: name , emoji: emoji, cases: Int(total))
        countrycases.append(data)
    }
    
    func fetchCoord(_ code : String) -> [Double]{
        let countryCode = code.lowercased()
        let coord = countryCoord.filter { $0.key == countryCode}
        return coord.first?.value ?? [0.0]
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
        
        cell.country = country
        
        cell.setupCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)    /// Deselect Row
        
        
        // Check to see which table view cell was selected.
        if tableView === self.tableView {
            let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
            let country = fetchCountry(cell.name ?? "india")
            let worldData = objectToStruct(country!)
            
            self.countryRootView = CountryDetailView(worldData: worldData, hello: cell.countryNameLabel.text ?? "no",slug: country!.slug ?? "india")
        } else {
            let cell = resultsTableController.tableView.cellForRow(at: indexPath) as! HomeTableViewCell
            let country = fetchCountry(cell.name ?? "india")
            let worldData = objectToStruct(country!)
            
            self.countryRootView = CountryDetailView(worldData: worldData, hello: cell.countryNameLabel.text ?? "no",slug: country!.slug ?? "india")
        }
        
        performSegue(withIdentifier: "countryData", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
}

extension HomeViewController : NSFetchedResultsControllerDelegate {
    
    //MARK:- Set FetchedResultsViewController
    func setupFetchedResultsController(sort : NSSortDescriptor) {
        let fetchRequest : NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
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

extension HomeViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults(for: searchController.searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        setupFetchedResultsController(sort: sort)    /// Setup fetchedResultsController
    }
    
    func updateSearchResults(for searchbar: UISearchBar) {
        if let text = searchbar.text{
            if text.count > 0 {
                
                let fetchRequest : NSFetchRequest<Country> = Country.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", text)
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController.delegate = self
                do{
                    try fetchedResultsController.performFetch()
                } catch {
                    fatalError(error.localizedDescription)
                }
                let filteredResults = fetchedResultsController.fetchedObjects
                if let resultsController = searchController.searchResultsController as? ResultsTableViewController {
                    resultsController.filteredProducts = filteredResults!
                    resultsController.tableView.reloadData()
                    
                    resultsController.filteredProducts.isEmpty ? print("EMpty") : print("NOT EMPTY")
                    //TODO add empty label
                    
                }
            }
        }
        
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
