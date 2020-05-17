//
//  Country.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation
import UIKit

struct CountryData : Codable{
    let countries : [Country]
}

struct Country : Codable{
    let Country : String
    let Slug : String
    let ISO2 : String
}


//let landmarkData: [Country] = load("landmarkData.json")
