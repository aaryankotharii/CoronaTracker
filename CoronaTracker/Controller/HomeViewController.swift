//
//  HomeViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let cellIdentifier = "cell"
    
    var summary : Summary?{
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CoronaClient.getSummary(completion: handleSummary(summary:error:))
    }
    
    func handleSummary(summary:Summary? ,error:Error?){
        if let summary = summary {
            print(summary)
            self.summary = summary
            return
        }
        print(error!.localizedDescription)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summary?.Countries.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HomeTableViewCell
        
        let country = summary?.Countries[indexPath.row]
        
        let name = country?.Country
        
        let emoji = convertToEmoji(str: country?.CountryCode ?? "") //TODO add default code
        
        cell.countryNameLabel.text = "\(emoji) \(name)"
        
        return cell
        
    }
    
    
}


