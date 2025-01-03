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
    @Published var foundCustomerInfo: CustomerSearchInfo?
    
    struct CustomerSearchInfo: Equatable {
        let id: Int
        let name: String
        let phone: String
    }
    
    func clearSearch() {
        print("Clearing search state")
        searchText = ""
        ticket = nil
        customerTickets = []
        foundCustomerInfo = nil
    }
    
    func searchTicket() async {
        guard !searchText.isEmpty else {
            showError("Please enter a ticket number or phone number")
            return
        }
        
        func searchTicket() async {
            guard !searchText.isEmpty else { return }
            
            startLoading()
            customerTickets = [] // Clear current tickets
            ticket = nil // Clear current ticket
        }
        
        startLoading()
        
        do {
            if searchText.count == 5 && searchText.allSatisfy({ $0.isNumber }) {
                print("Performing ticket search for: \(searchText)")
                let data = try await NetworkService.shared.getTicketStatus(searchText)
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let ticketResponse = try decoder.decode(TicketResponse.self, from: data)
                self.ticket = ticketResponse.ticket
                
                if let ticket = self.ticket {
                    print("Successfully found ticket: #\(ticket.number)")
                    
                    // Fetch all tickets for this customer
                    let customerTicketsData = try await NetworkService.shared.getTicketsByCustomerId(ticket.customerId)
                    let ticketsResponse = try decoder.decode(TicketsResponse.self, from: customerTicketsData)
                    
                    print("Found \(ticketsResponse.tickets.count) tickets for customer")
                    
                    // Sort tickets - searched ticket first, then by date
                    self.customerTickets = ticketsResponse.tickets.sorted { ticket1, ticket2 in
                        if ticket1.number == searchText {
                            return true
                        } else if ticket2.number == searchText {
                            return false
                        }
                        return ticket1.createdAt > ticket2.createdAt
                    }
                    
                    // Update foundCustomerInfo
                    self.foundCustomerInfo = CustomerSearchInfo(
                        id: ticket.customerId,
                        name: ticket.customerName,
                        phone: searchText
                    )
                    
                    print("""
                        Updated customer info:
                        - ID: \(ticket.customerId)
                        - Name: \(ticket.customerName)
                        - Total Tickets: \(self.customerTickets.count)
                        """)
                } else {
                    print("No ticket found in response")
                    showError("No ticket found with this number")
                }
            } else {
                print("Performing phone number search")
                let response = try await NetworkService.shared.searchCustomerInfoByPhone(searchText)
                
                if let firstResult = response.results.first {
                    let customerId = firstResult.table._id
                    print("Found customer ID: \(customerId)")
                    
                    self.foundCustomerInfo = CustomerSearchInfo(
                        id: customerId,
                        name: "\(firstResult.table._source.table.firstname) \(firstResult.table._source.table.lastname)",
                        phone: searchText
                    )
                    
                    let ticketsData = try await NetworkService.shared.getTicketsByCustomerId(customerId)
                    
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    print("Fetching tickets for customer")
                    let ticketsResponse = try decoder.decode(TicketsResponse.self, from: ticketsData)
                    
                    // Sort tickets by creation date (newest first)
                    self.customerTickets = ticketsResponse.tickets.sorted {
                        $0.createdAt > $1.createdAt
                    }
                    
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

struct UserInfo: Codable, Equatable {
    let id: Int
    let email: String
    let full_name: String
    let group: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, full_name, group, color
    }
    
    static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
