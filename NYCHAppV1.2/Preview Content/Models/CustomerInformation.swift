//
//  Untitled.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftData
import Foundation

@Model
final class CustomerInformation {
    var phoneNumber: String
    var customerID: Int
    var customerName: String
    var timestamp: Date
    
    init(phoneNumber: String, customerID: Int, customerName: String) {
        self.phoneNumber = phoneNumber
        self.customerID = customerID
        self.customerName = customerName
        self.timestamp = Date()
    }
}
