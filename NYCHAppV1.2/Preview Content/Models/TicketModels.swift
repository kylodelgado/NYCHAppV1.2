//
//  TicketModels.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//


import Foundation
import Foundation

// MARK: - Ticket Request Models
struct TicketItem: Codable {
    let customerId: Int
    let subject: String
    let status: String
    let properties: [String: String]
    let commentsAttributes: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case customerId = "customer_id"
        case subject, status, properties
        case commentsAttributes = "comments_attributes"
    }
}

struct Comment: Codable {
    let subject: String
    let body: String
    let hidden: Bool
    let tech: String
}

// MARK: - Ticket Response Models
struct TicketResponse: Codable {
    let ticket: TicketDetails
}

struct TicketDetails: Codable {
    let id: Int
    let number: String
    let subject: String
    let status: String
    let createdAt: Date
    let updatedAt: Date
    let dueDate: Date?
    let resolvedAt: Date?
    let customerId: Int
    let customer_business_then_name: String
    let properties: [String: String]
    let comments: [TicketComment]
    let problem_type: String?
    let billing_status: String?
    let user: UserInfo?
    let customer: Customer?  // Make this optional
    
    enum CodingKeys: String, CodingKey {
        case id, number, subject, status, properties, comments, customer
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case dueDate = "due_date"
        case resolvedAt = "resolved_at"
        case customerId = "customer_id"
        case customer_business_then_name
        case problem_type
        case billing_status
        case user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        if let numberInt = try? container.decode(Int.self, forKey: .number) {
            number = String(numberInt)
        } else {
            number = try container.decode(String.self, forKey: .number)
        }
        subject = try container.decode(String.self, forKey: .subject)
        status = try container.decode(String.self, forKey: .status)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        resolvedAt = try container.decodeIfPresent(Date.self, forKey: .resolvedAt)
        customerId = try container.decode(Int.self, forKey: .customerId)
        properties = try container.decode([String: String].self, forKey: .properties)
        comments = try container.decode([TicketComment].self, forKey: .comments)
        customer = try? container.decodeIfPresent(Customer.self, forKey: .customer)
        customer_business_then_name = try container.decode(String.self, forKey: .customer_business_then_name)
        problem_type = try container.decodeIfPresent(String.self, forKey: .problem_type)
        billing_status = try container.decodeIfPresent(String.self, forKey: .billing_status)
        user = try? container.decodeIfPresent(UserInfo.self, forKey: .user)
    }
    
    // Computed properties for convenience
    var customerName: String {
        return customer?.fullname ?? customer_business_then_name
    }
    
    var customerBusinessName: String? {
        return customer?.businessName
    }
}
// Add Customer struct
struct Customer: Codable {
    let id: Int
    let firstname: String
    let lastname: String
    let fullname: String
    let businessName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, firstname, lastname, fullname
        case businessName = "business_name"
    }
}
struct TicketComment: Codable {
    let id: Int
    let subject: String?
    let body: String?
    let tech: String?
    let hidden: Bool
    let createdAt: Date
    

    enum CodingKeys: String, CodingKey {
        case id, subject, body, tech, hidden
        case createdAt = "created_at"
    }
}

struct Ticket: Identifiable, Codable {
    let id: Int
}

struct TicketItems: Codable {
    let tickets: [Ticket]
}
