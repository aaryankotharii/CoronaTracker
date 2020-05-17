//
//  CoronaClient.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

class CoronaClient {
    
    //MARK:- ENDPOINT URLS
    enum Endpoints {
        
        static let base = "https://api.covid19api.com"
        
        case countries
        case summary
        case dayone(country:String)
        case dayonelive(country:String)
        case dayonetotal(country:String)
        
        var stringValue : String{
            switch self {
            case .countries:
                return Endpoints.base + "/countries"
            case .summary:
                return Endpoints.base + "/summary"
            case .dayone(let country):
                 return Endpoints.base + "/dayone/country/\(country)"
            case .dayonelive(let country):
                return Endpoints.base + "/dayone/country/\(country)/status/confirmed/live"
            case .dayonetotal(let country):
                return Endpoints.base + "/dayone/country/\(country)/status/confirmed"
            }
        }
        
        var url : URL {
            return URL(string: self.stringValue)!
        }
    }
    
}
