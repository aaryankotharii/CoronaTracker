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
    var countries : [CountryStruct]
}

struct CountryStruct : Codable{
    var Country: String
    var CountryCode: String
    var Province:String
    var City: String
    var CityCode: String
    var Lat: String
    var Lon: String
    var Confirmed: Int
    var Deaths: Int
    var Recovered: Int
    var Active: Int
    var Date: String
}
