//
//  Summary.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation


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
