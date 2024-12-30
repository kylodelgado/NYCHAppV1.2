//
//  Untitled.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftData
import SwiftUI
import Foundation

@Model
class CustomerInformation {
    var customerID: Int
    var timestamp: Date
    var id: UUID
    
    init(customerID: Int) {
        self.customerID = customerID
        self.timestamp = Date()
        self.id = UUID()
    }
}
