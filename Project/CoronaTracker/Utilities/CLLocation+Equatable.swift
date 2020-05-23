//
//  CLLocation+Equatable.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 12/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D: Equatable {}

// MAKES COORDINATE EQUATABLE
public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
