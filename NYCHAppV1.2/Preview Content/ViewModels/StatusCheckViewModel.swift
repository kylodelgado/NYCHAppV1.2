//
//  StatusCheckViewModel.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

import SwiftUI

@MainActor
class StatusCheckViewModel: BaseViewModel {
    @Published var searchText = ""
    @Published var ticket: TicketDetails?
    
    func searchTicket() async {
        guard !searchText.isEmpty else {
            showError("Please enter a ticket number")
            return
        }
        
        startLoading()
        
        do {
            let data = try await NetworkService.shared.getTicketStatus(searchText)
            let decoder = JSONDecoder()
            
            // Create custom date formatter to match API date format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            // Decode the wrapped response
            let ticketResponse = try decoder.decode(TicketResponse.self, from: data)
            self.ticket = ticketResponse.ticket
            
        } catch {
            showError(error.localizedDescription)
        }
        
        stopLoading()
    }
}
