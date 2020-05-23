//
//  ResultsTableViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 20/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

//MARK:- RESULTS TABLE VIEW ( USED UNDER SEARCH CONTROLLER )

//MARK: Cell is same as HomeViewController

class ResultsTableViewController: UITableViewController {
    
    let tableViewCellIdentifier = "cell2"
    
    var filteredProducts = [Country]()
    
    // MARK: - UITableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! HomeTableViewCell
        
        let country = filteredProducts[indexPath.row]
        
        cell.country = country
        
        cell.setupCell()
    
        return cell
        
    }
}
