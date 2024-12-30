////
////  DataModel.swift
////  NYCHAppV1.2
////
////  Created by Brandon Delgado on 12/11/24.
////
//
//import Foundation
//import SwiftData
//
//
//@Model
//class CustomerInfomation {
//    var customerID: Int
//    
//    init(customerID: Int) {
//        self.customerID = customerID
//    }
//}
//
//
//
//// structs
//struct TicketData: Codable {
//    let tickets: [Ticket]
//}
//
//struct Ticket: Codable {
//    let id: Int?
//    let subject: String
//    let number: Int
//    let customer_business_then_name: String
//    let createdAt: String?
//    let status: String?
//    let locationName: String?
//    let problemType: String?
//    let customerId: Int?
//    let customerBusinessThenName: String?
//   // let comments: [Comment]
//}
//
//
//
//
//func fetchAndDecodeTicketDetails(byTickerNumber: String) async throws -> TicketData {
//    
//
//    
//    guard let url = URL(string: "https://nych.repairshopr.com/api/v1/tickets?number=\(byTickerNumber)") else {
//        throw URLError(.badURL)
//    }
//
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    request.setValue("application/json", forHTTPHeaderField: "accept")
//    request.setValue("T5b51cee4f21d46aaa-b7650daffe9eb74b1ffdccc3a01abe40", forHTTPHeaderField: "Authorization")
//
//    let (data, _) = try await URLSession.shared.data(for: request)
//
//    let decoder = JSONDecoder()
//    return try decoder.decode(TicketData.self, from: data)
//}
//
//
//
//
///// Form to create a customer 
