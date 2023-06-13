//
//  Recording.swift
//  Larynx
//
//  Created by Stef Kors on 07/06/2023.
//

import Foundation
import SwiftData

@Model
final class Recording {
    let createdAt: Date
    var data: Data

    init(createdAt: Date, data: Data) {
        self.createdAt = createdAt
        self.data = data
    }
}
