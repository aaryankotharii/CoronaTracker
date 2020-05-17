//
//  Country.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

struct CountryData : Codable{
    let countries : [Country]
}

struct Country : Codable{
    let Country : String
    let Slug : String
    let ISO2 : String
}
