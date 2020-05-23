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
    @Published var current : [[Double]]?

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
            let confirmedArray = confirmed.map{ Double($0)}
            
            self.current = [confirmedArray,
                            recoveredArray,
                            deathArray,
                            activeArray]
                  }
        }
}
