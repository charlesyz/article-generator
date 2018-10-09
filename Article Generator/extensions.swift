//
//  extensions.swift
//  Article Generator
//
//  Created by Charles Zhang on 2018-08-28.
//  Copyright © 2018 Firebird Studios. All rights reserved.
//

import Foundation

// extensions to allow the dictionary to search both ways (key -> result, result -> key)
// usage: dict.key(forValue: 3)
extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}
