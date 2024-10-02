//
//  Item.swift
//  Corg2
//
//  Created by Felix Haag on 02.10.24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
