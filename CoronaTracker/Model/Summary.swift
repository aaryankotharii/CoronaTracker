//
//  Summary.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation


struct Summary {
    var global : Global
    var countries : [Countries]
}

struct Global {
    var newConfirmed : Int
    var  totalConfirmed: Int
    var newDeaths : Int
    var totalDeaths : Int
    var newRecovered : Int
    var  totalRecovered : Int
}

struct Countries {
    var country: String
    var countryCode : String
    var slug: String
    var newConfirmed: Int
    var totalConfirmed: Int
    var newDeaths: Int
    var totalDeaths: Int
    var newRecovered: Int
    var totalRecovered: Int
    var  date: Date
}
