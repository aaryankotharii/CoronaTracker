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
    @Published  var current : CountryData?
    
    var dataList =  [CountryData?]()
    
    var deathList = [Double]()
    
    init(){
        self.fetch()
    }
}

extension CurrentCountryData{
    func fetch(_ country: String = "india"){
        CoronaClient.getCountryLive(country: country){ result in
            self.current?.countries = result ?? []
            print(result)
        }
    }
}
