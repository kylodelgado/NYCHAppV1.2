//
//  StatusCheckViewModel.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI
import SwiftData

@MainActor

class StatusCheckViewModel: BaseViewModel {
    @Published var searchText = ""
    @Published var ticket: TicketDetails?
    @Published var customerTickets: [TicketDetails] = []
    
    func searchTicket() async {
        guard !searchText.isEmpty else {
            showError("Please enter a ticket number or phone number")
            return
        }
        
        startLoading()
        
        do {
            if searchText.count == 5 && searchText.allSatisfy({ $0.isNumber }) {
                let data = try await NetworkService.shared.getTicketStatus(searchText)
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let ticketResponse = try decoder.decode(TicketResponse.self, from: data)
                self.ticket = ticketResponse.ticket
                self.customerTickets = []
                print(customerTickets[0].customerId)
                
            } else {
                print("Performing phone number search")
                let response = try await NetworkService.shared.searchCustomerInfoByPhone(searchText)
                
                if let firstResult = response.results.first {
                    let customerId = firstResult.table._id
                    print("Found customer ID: \(customerId)")
                    
                    let ticketsData = try await NetworkService.shared.getTicketsByCustomerId(customerId)
                    
                    if let jsonString = String(data: ticketsData, encoding: .utf8) {
                        print("Raw tickets response: \(jsonString)")
                    }
                    
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    print("Fetching tickets for customer")
                    let ticketsResponse = try decoder.decode(TicketsResponse.self, from: ticketsData)
                    
                    // Add debug prints for problem_type
                    for ticket in ticketsResponse.tickets {
                        print("Ticket #\(ticket.number) - Problem Type: \(String(describing: ticket.problem_type))")
                    }
                    
                    self.customerTickets = ticketsResponse.tickets
                    print("Found \(self.customerTickets.count) tickets")
                    self.ticket = nil
                } else {
                    print("No customer found")
                    showError("No customer found with this phone number")
                }
            }
        } catch {
            print("Search error: \(error)")
            if let decodingError = error as? DecodingError {
                print("Decoding error details: \(decodingError)")
            }
            showError(error.localizedDescription)
        }
        
        stopLoading()
    }
}





struct TicketsResponse: Codable {
    let tickets: [TicketDetails]
    let meta: Meta
}

struct Meta: Codable {
    let total_pages: Int
    let page: Int
}

struct UserInfo: Codable {
    let id: Int
    let email: String
    let full_name: String
    let group: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, full_name, group, color
    }
}
