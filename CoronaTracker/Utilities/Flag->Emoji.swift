//
//  Flag->Emoji.swift
//  CoronaTracker
//
//  Created by Aaryan Kothari on 17/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import Foundation

func convertToEmoji(str: String) -> String {
    let lowercased = str.lowercased()
    
    guard lowercased.count == 2 else { return "" }
    
    // 0x1F1E6 is first in the Regional Indicator Symbol range, 'A'
    // 0x61 is the first in the lowercase ASCII alphabet, 'a'
    let regionalIndicators = lowercased.unicodeScalars.map { UnicodeScalar($0.value + (0x1F1E6 - 0x61))! }
    
    return String(regionalIndicators.map { Character($0) })
}
