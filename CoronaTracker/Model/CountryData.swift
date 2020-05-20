//
//  CountryData.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 18/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation
import Combine

final class CurrentCountryData: ObservableObject {
    @Published  var current : CountryCaseCount?
    
    @Published var active : [Double]?
    @Published var dead : [Double]?
    @Published var Recovered : [Double]?
    @Published var confirmed : [Double]?
    
    
    @Published var dailyNew : [Double]?

    
    init(){
        self.fetch()
    }
}

extension CurrentCountryData{
    func fetch(_ country: String = "india"){
        CoronaClient.getCountryLive(country: country){ result in
            let deaths = result.map { $0.Deaths}
            let deathArray = deaths.map{Double($0)}
            
            let active = result.map { $0.Active }
            let activeArray = active.map{Double($0)}

                let recovered = result.map { $0.Recovered }
            let recoveredArray = recovered.map{Double($0)}
            
            let confirmed = result.map { $0.Confirmed }
            let confirmedArray = confirmed.map{ Double($0) }

            self.current = CountryCaseCount(active: activeArray, deaths: deathArray, recovered: recoveredArray)
            self.active = activeArray
            self.dead = deathArray
            self.Recovered = recoveredArray
            self.confirmed = confirmedArray

            var arrayToReturn = confirmedArray
                if arrayToReturn.count >= 0{
                    for i in stride(from: (arrayToReturn.count-1), to: 1, by: -1) {
                        arrayToReturn[i] = arrayToReturn[i] - arrayToReturn[i-1]
                        self.dailyNew = arrayToReturn
                  }
              }
            
        }
    }
    
    func getFrequencyArray(_ array : [Double]?)->[Double]{
        var arrayToReturn = array
        if arrayToReturn != nil{
            if arrayToReturn!.count >= 0{
            for i in stride(from: (arrayToReturn!.count-1), to: 1, by: -1) {
                      arrayToReturn![i] = arrayToReturn![i] - arrayToReturn![i-1]
                return arrayToReturn ?? []
              }
          }
        }
        return []
    }
}

