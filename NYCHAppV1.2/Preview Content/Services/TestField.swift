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
            
            Task {
                do {
                    let status = try await getTicketStatus("44653")
                    print(status)
                    
                    
                } catch {
                    print("Catched Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    TestField()
}

//
//func getTicketID(_ number: String) async throws -> Int {
//
//    
//}

func getTicketStatus(_ number: String) async throws -> Data {
    // Validate ticket number
    guard number.count == 5 else {
       throw NetworkError.invalidRequest
    }
    
    // First request to get ticket ID
    guard let url = URL(string: "\(APIConfig.baseURL)/tickets?number=\(number)") else {
        throw NetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue(APIConfig.apiKey, forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.invalidResponse
    }
    
    let decoder = JSONDecoder()
    
    // Create custom date formatter
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  // This format matches the API response
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    
    // Decode first response to get ticket ID
    let ticketArray = try decoder.decode(TicketItems.self, from: data)
    guard let firstTicket = ticketArray.tickets.first else {
        throw NetworkError.invalidRequest
    }
    
    // Second request using the obtained ticket ID
    guard let url1 = URL(string: "\(APIConfig.baseURL)/tickets/\(firstTicket.id)") else {
        throw NetworkError.invalidURL
    }
    
    var request1 = URLRequest(url: url1)
    request1.setValue("application/json", forHTTPHeaderField: "Accept")
    request1.setValue(APIConfig.apiKey, forHTTPHeaderField: "Authorization")
    
    let (data1, response1) = try await URLSession.shared.data(for: request1)
    
    guard let httpResponse1 = response1 as? HTTPURLResponse,
          (200...299).contains(httpResponse1.statusCode) else {
        throw NetworkError.invalidResponse
    }
    
    // Use the same decoder for the second request
    let ticketResponse = try decoder.decode(TicketResponse.self, from: data1)
    print(ticketResponse.ticket)
    
    return data1
}

//let ticketID = try await getTicketID(number)
//let decoder = JSONDecoder()
//decoder.dateDecodingStrategy = .iso8601
//
//let ticketDetails = try decoder.decode(TicketItems.self, from: ticketID)
//
//guard let ticketdetailsID = ticketDetails.tickets.first?.id else {
//    throw NetworkError.invalidResponse
//}

//
//Task {
//
//    do {
//        let data = try await getTicketID("40000")
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601  // For handling date formats from API
//
//
//        let ticketDetails = try decoder.decode(TicketItems.self, from: data)
//        print(ticketDetails.tickets.first?.id ?? "No ID")
//
//    } catch {
//        print("Data does not compute")
//    }
//}
