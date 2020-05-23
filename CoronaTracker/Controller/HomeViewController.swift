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
    
    //MARK:- Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var globeButton: UIButton!
    
    /// Managed object context  to `save` data to Database
    var moc : NSManagedObjectContext!
    
    /// Fetched Results controller to `fetch` data from Database
    var fetchedResultsController : NSFetchedResultsController<Country>!
    
    /// Search controller to help us with filtering items in the table view.
    var searchController: UISearchController!
    
    /// `Search` results table view.
    private var resultsTableController: ResultsTableViewController!
    
    /// `Sorts` The results for tabelView
    var sort =  NSSortDescriptor(key: "name", ascending: true)
    
    var countrycases : [countrycase] = []
    
    var countryRootView = CountryDetailView(data: [])
    
    let cellIdentifier = "cell"
    let heightForCell : CGFloat = 170
    
    //MARK:- ACTIVITY INDICATOR
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadList),for: UIControl.Event.valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.09505660087, green: 0.8000571132, blue: 0.7261177897, alpha: 1)
        
        return refreshControl
    }()
    
    //MARK:-  ---------- Life Cycle Methods ----------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "onboarding") == nil {
        performSegue(withIdentifier: "onboarding", sender: nil)
        }
        setupSearchController()
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.searchController = searchController
    }
    
    //MARK:-  ---------- Outlets ----------
    
    /// Segue  To `CountryDetailView`
    @IBSegueAction func goToCountryData(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: countryRootView)
    }
    
    /// Segue  To `GlobeView`
    @IBSegueAction func goToGlobalData(_ coder: NSCoder) -> UIViewController? {
        let country = fetchCountry("Algeria")
        let globalRootView = GlobeView(country: country!, cases: [])
        return UIHostingController(coder: coder, rootView: globalRootView .environment(\.managedObjectContext, self.moc))
    }
    
    ///  `Reload` Data
    @IBAction func reloadClicked(_ sender: Any) {
        CoronaClient.getSummary(completion: handleUpdate(summary:error:))
    }
    
    ///  `Sort` Data
    @IBAction func sortClicked(_ sender: UIButton) {
        if sender.tag == 0{
            presentAlert(false)
        } else {
            presentAlert(true)
        }
    }
    
    @objc func loadList(){
        CoronaClient.getSummary(completion: handleUpdate(summary:error:))
    }
    
    fileprivate func setupSearchController() {
        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableViewController
        resultsTableController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
    }
    
    
    func initialSetup() {
        
        /// MOC setup
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        moc = appDelegate.persistentContainer.viewContext
        
        /// FETCH DATA
        let sort = NSSortDescriptor(key: "name", ascending: true)
        setupFetchedResultsController(sort: sort)    /// Setup fetchedResultsController
        if fetchedResultsController.fetchedObjects?.count == 0{
            CoronaClient.getSummary(completion: handleDownload(summary:error:))
        } else {
            CoronaClient.getSummary(completion: handleUpdate(summary:error:))
        }
        resultsTableController.filteredProducts  = fetchedResultsController.fetchedObjects!
        tableView.addSubview(refreshControl)
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
            if error!.localizedDescription == "The Internet connection appears to be offline."{
                self.networkErrorAlert(title: "Internet required to download data")
                if refreshControl.isRefreshing { refreshControl.endRefreshing() }
            }
            return
                print(error!.localizedDescription,"error",error.debugDescription)
        }
    }
    
    func handleUpdate(summary:Summary? ,error:Error?){
        countrycases.removeAll()
        if let summary = summary {
            for country in summary.Countries{
                updateCountry(country)
                objectToGlobalStruct(country)
            }
            if refreshControl.isRefreshing { refreshControl.endRefreshing() }   /// STOP REFRESH IF ACTIVE
        } else {
            if error!.localizedDescription == "The Internet connection appears to be offline."{
                self.networkErrorAlert(title: "Internet required to update data")
                if refreshControl.isRefreshing { refreshControl.endRefreshing() }
            }
            print(error!.localizedDescription,"error",error.debugDescription)
            return
        }
    }
    
    /// Function to save countries to database
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
    
    /// Function to save Global data  to database
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
    
    /// Converts NSManagesObject to Struct
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


//MARK:- TableViewDelegate + TableViewDataSource Methods
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
            let data = [[worldData.NewConfirmed,worldData.TotalConfirmed],[worldData.NewRecovered,worldData.TotalRecovered],[worldData.NewDeaths,worldData.TotalDeaths],[0,worldData.totalActive()]]
            self.countryRootView = CountryDetailView(worldData: worldData, data: data, countryName: cell.countryNameLabel.text ?? "no", slug: country!.slug ?? "india")
           
        } else {
            let cell = resultsTableController.tableView.cellForRow(at: indexPath) as! HomeTableViewCell
            let country = fetchCountry(cell.name ?? "india")
            let worldData = objectToStruct(country!)
            let data = [[worldData.NewConfirmed,worldData.TotalConfirmed],[worldData.NewRecovered,worldData.TotalRecovered],[worldData.NewDeaths,worldData.TotalDeaths],[0,worldData.totalActive()]]
           self.countryRootView = CountryDetailView(worldData: worldData, data: data, countryName: cell.countryNameLabel.text ?? "no", slug: country!.slug ?? "india")
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "countryData", sender: nil)
        }
}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForCell
    }
    

}

//MARK:- FetchedResultsController Delegate Methods
extension HomeViewController : NSFetchedResultsControllerDelegate {
    
    //MARK:- Set FetchedResultsViewController
    func setupFetchedResultsController(sort : NSSortDescriptor) {
        let fetchRequest : NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = [sort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
}


//MARK:- SearchController Delegate Methods
extension HomeViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateSearchResults(for: searchController.searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
                }
            }
        }
    }
}

//MARK:- SORT ACTION SHEET FUNCTIONS
extension HomeViewController {
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
}
