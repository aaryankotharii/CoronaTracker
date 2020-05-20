//
//  ResultsTableViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 20/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    let tableViewCellIdentifier = "cell2"
    

        
        var filteredProducts = [Country]()
                
        override func viewDidLoad() {
            super.viewDidLoad()
            print(filteredProducts,"FFFFFFFFF")
        }
        
        // MARK: - UITableViewDataSource
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredProducts.count
       }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! HomeTableViewCell
             
            let country = filteredProducts[indexPath.row]
             
             let name = country.name
             
             let emoji = convertToEmoji(str: country.countrycode ?? "") //TODO add default code
             
             let date = country.date ?? Date()
             
             cell.timeLabel.text = date.homeCellDate
             
             
             cell.countryNameLabel.text = "\(emoji) \(name ?? "")"
             
             
             cell.total = Int(country.total)
             cell.deaths = Int(country.deaths)
             cell.recovered = Int(country.recoveries)
             
             cell.name = name ?? ""
             
             cell.setupLabels()
             
             return cell        }
    }
