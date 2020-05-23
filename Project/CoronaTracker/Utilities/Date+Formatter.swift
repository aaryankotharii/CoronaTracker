//
//  Date+Formatter.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 20/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

//MARK: Formats date for tableView cell
extension Date{
    var homeCellDate: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d H:mm"
        let dateString = formatter.string(from: Date())
        return dateString
    }
}
