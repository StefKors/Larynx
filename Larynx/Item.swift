//
//  Item.swift
//  Larynx
//
//  Created by Stef Kors on 07/06/2023.
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
