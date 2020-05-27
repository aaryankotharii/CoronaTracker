//
//  TodayViewController.swift
//  Today Extension
//
//  Created by Aaryan Kothari on 27/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation


class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    @IBOutlet var totalLabel: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("appear")
        var currentSize: CGSize = self.preferredContentSize
        currentSize.height = 100.0
        self.preferredContentSize = currentSize
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        getSummary { (result, error) in
            if let result = result{
                self.totalLabel.text = "\(result.Countries[0].TotalConfirmed)"
                completionHandler(NCUpdateResult.newData)
            } else {
                
                completionHandler(.failed)
                
            }
        }
    }
    
    func getSummary(completion: @escaping (Summary?, Error?) -> Void){
        
        let url =  URL(string: "https://api.covid19api.com/summary")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(Summary.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch{
                completion(nil,error)
            }
        }
        task.resume()
    }
    
 
}




struct Summary : Codable{
    var Global : GlobalData
    var Countries : [Countries]
}

struct GlobalData: Codable {
    var NewConfirmed : Int
    var  TotalConfirmed: Int
    var NewDeaths : Int
    var TotalDeaths : Int
    var NewRecovered : Int
    var  TotalRecovered : Int
}

struct Countries: Codable {
    var Country: String
    var CountryCode : String
    var Slug: String
    var NewConfirmed: Int
    var TotalConfirmed: Int
    var NewDeaths: Int
    var TotalDeaths: Int
    var NewRecovered: Int
    var TotalRecovered: Int
    var  Date: String
    
    func totalActive()->Int{
        return TotalConfirmed - TotalDeaths - TotalRecovered
    }
}
