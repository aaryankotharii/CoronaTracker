//
//  HomeViewController.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CoronaClient.getSummary(completion: handleSummary(summary:error:))
    }
    
    func handleSummary(summary:Summary? ,error:Error?){
        if let summary = summary {
            print(summary)
            return
        }
        print(error!.localizedDescription)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}


