//
//  SortingData.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 23/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

enum SortType{
    case name(state : Bool)
    case death
    case recovered
    case total
    case state(state : Bool)
    
    var stringValue : String {
        switch self {
        case .death:
            return "Deaths"
        case .name(state: let state):
            return state ? "Name (A - Z)" : "Name (Z - A)"
        case .recovered:
            return "Recovered "
        case .total:
            return  "Total"
        case .state(let state):
            return state ? "Lowest First" : "Highest First"
        }
    }
}
