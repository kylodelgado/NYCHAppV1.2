//
//  NetworkService.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//
import Foundation

// MARK: - API Configuration
enum APIConfig {
    static let baseURL = "https://nych.repairshopr.com/api/v1"
    static let apiKey = "T5b51cee4f21d46aaa-b7650daffe9eb74b1ffdccc3a01abe40" // We'll move this to more secure storage later
}

// MARK: - Network Error Types
enum NetworkError: Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case invalidData
    case serverError(String)
    
    var errorDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidRequest: return "Invalid request"
        case .invalidResponse: return "Invalid response from server"
        case .invalidData: return "Invalid data received"
        case .serverError(let message): return "Server error: \(message)"
        }
    }
}

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    func createCustomer(_ customer: CustomerInfo) async throws -> Data {
        guard let url = URL(string: "\(APIConfig.baseURL)/customers") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(customer)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
    
    func createTicket(_ ticket: TicketItem) async throws -> Data {
        guard let url = URL(string: "\(APIConfig.baseURL)/tickets") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(ticket)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
    
    func getTicketID(_ number: String) async throws -> String {
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
        decoder.dateDecodingStrategy = .iso8601
        
        let ticketArray = try decoder.decode(TicketItems.self, from: data)
        guard let ticket = ticketArray.tickets.first else {
            return "No Ticket"
        }
        
        return String(ticket.id)
    }
    
    
    
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
    


    
}