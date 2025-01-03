//
//  CustomerModels.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//


import Foundation

struct CustomerInfo: Codable {
    let businessName: String
    let firstname: String
    let lastname: String
    let email: String
    let phone: String
    let mobile: String
    let address: String
    let address2: String
    let city: String
    let state: String
    let zip: String
    let notes: String
    let getSms: Bool
    let optOut: Bool
    let noEmail: Bool
    let getBilling: Bool
    let getMarketing: Bool
    let getReports: Bool
    let refCustomerId: Int
    let referredBy: String
    let taxRateId: Int
    let notificationEmail: String
    let invoiceCcEmails: String
    let invoiceTermId: Int
    let properties: [String: String]
    let consent: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case businessName = "business_name"
        case firstname, lastname, email, phone, mobile
        case address
        case address2 = "address_2"
        case city, state, zip, notes
        case getSms = "get_sms"
        case optOut = "opt_out"
        case noEmail = "no_email"
        case getBilling = "get_billing"
        case getMarketing = "get_marketing"
        case getReports = "get_reports"
        case refCustomerId = "ref_customer_id"
        case referredBy = "referred_by"
        case taxRateId = "tax_rate_id"
        case notificationEmail = "notification_email"
        case invoiceCcEmails = "invoice_cc_emails"
        case invoiceTermId = "invoice_term_id"
        case properties, consent
    }
}

struct CustomerResponse: Codable {
    let customer: CustomerDetails
}

struct CustomerDetails: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "firstname"
        case lastName = "lastname"
        case email
    }
}

struct CustomerDetail: Codable {
    let id: Int
    let firstname: String
    let lastname: String
    let fullname: String
}

struct PhoneSearchResponse: Codable {
    let results: [PhoneSearchResult]
}

struct PhoneSearchResult: Codable {
    let table: PhoneSearchTable
}

struct PhoneSearchTable: Codable {
    let _id: Int
    let _source: PhoneSearchSource
}

struct PhoneSearchSource: Codable {
    let table: PhoneSearchTableDetails
}

struct PhoneSearchTableDetails: Codable {
    let firstname: String
    let lastname: String
}


struct CustomerSearchMeta: Codable {
    let total_pages: Int
    let total_entries: Int
    let per_page: Int
    let page: Int
}


 
struct CustomerPhoneSearchResponse: Codable {
    let quick_result: String?
    let results: [CustomerPhoneResult]
    let error: String?
}

struct CustomerPhoneResult: Codable {
    let table: CustomerPhoneTableInfo
}

struct CustomerPhoneTableInfo: Codable {
    let _id: Int
    let _type: String
    let _index: String
    let _source: CustomerPhoneSourceInfo
}

struct CustomerPhoneSourceInfo: Codable {
    let table: CustomerPhoneInfo
}

struct CustomerPhoneInfo: Codable {
    let firstname: String
    let lastname: String
    let email: String
    let business_name: String
    let phones: [CustomerPhone]
}

struct CustomerPhone: Codable {
    let id: Int
    let label: String
    let number: String
    let customer_id: Int
}

struct CustomerSearchResponse: Codable {
    let customers: [CustomerDetail]
}

// Add Customer struct
struct Customer: Codable, Equatable {
    let id: Int
    let firstname: String
    let lastname: String
    let fullname: String
    let businessName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, firstname, lastname, fullname
        case businessName = "business_name"
    }
    
    static func == (lhs: Customer, rhs: Customer) -> Bool {
        return lhs.id == rhs.id
    }
}
