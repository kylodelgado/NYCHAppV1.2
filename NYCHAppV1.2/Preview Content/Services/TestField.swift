//
//  TestField.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

struct TestField: View {
    
   
    
    var body: some View {
        
        Button("Tap Here") {
            
         
        }
    }
}

#Preview {
    StatusCheckViewModel1()
}

//
//func getTicketID(_ number: String) async throws -> Int {
//
//    
//}

struct StatusCheckViewModel1: View {
    
    @State var searchText = "44090"
    @State var ticket: TicketDetails?
    @State var customerTickets: [TicketDetails] = []
    
    var body: some View {
        
        VStack {
            Text("Hello")
            
            Button("Tap me") {
                Task {
                    
                    
                    do {
                        _ = await searchTicket1()
                    }
                }
            }
        }
        
    }
        
    func searchTicket1() async -> String {
            guard !searchText.isEmpty else {
                print("Please enter a ticket number or phone number")
                return ""
            }
            
            
            
            do {
                if searchText.count == 5 && searchText.allSatisfy({ $0.isNumber }) {
                    
                    print("Performing Ticket Search")
                    let data = try await NetworkService.shared.getTicketStatus(searchText)
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let ticketResponse = try decoder.decode(TicketResponse.self, from: data)
                    self.ticket = ticketResponse.ticket
                    self.customerTickets = []
                    if let firstResult = ticket {
                        return String(firstResult.customerId)
                    }
                   
                    
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
                        
     
                        
                        self.customerTickets = ticketsResponse.tickets
                        print("Found \(self.customerTickets.count) tickets")
                        self.ticket = nil
                    } else {
                        print("No customer found")
                        print("No customer found with this phone number")
                    }
                }
            } catch {
                print("Search error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Decoding error details: \(decodingError)")
                }
                print(error.localizedDescription)
            }
         return ""
        }
    
    
}

