//
//  CustomerViewModel.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

class CustomerViewModel: BaseViewModel {
    
    private func decodeCustomerID(jsonString: String) -> Int? {
        // Define the response structure
        struct CustomerIDResponse: Codable {
            let customer: CustomerID
        }

        struct CustomerID: Codable {
            let id: Int
        }
        
        // Convert string to data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(CustomerIDResponse.self, from: jsonData)
            return response.customer.id
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            return nil
        }
    }

    // Form Data
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var businessName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var address = ""
    @Published var city = ""
    @Published var state = "NY"
    @Published var zipCode = ""
    
    // Form State
    @Published var hasAttemptedSubmission = false
    @Published var customerCreated = false
    @Published var createdCustomerId: Int?
    
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        phone.count >= 10
    }
    
    func validateForm() -> Bool {
        hasAttemptedSubmission = true
        
        if firstName.isEmpty {
            showError("Please enter first name")
            return false
        }
        if lastName.isEmpty {
            showError("Please enter last name")
            return false
        }
        if !email.contains("@") {
            showError("Please enter a valid email")
            return false
        }
        if phone.count < 10 {
            showError("Please enter a valid phone number")
            return false
        }
        return true
    }
    
    @MainActor
    func createCustomer() async {
        guard validateForm() else { return }
        
        startLoading()
        
        let customerInfo = CustomerInfo(
            businessName: businessName,
            firstname: firstName,
            lastname: lastName,
            email: email,
            phone: phone,
            mobile: "",
            address: address,
            address2: "",
            city: city,
            state: state,
            zip: zipCode,
            notes: "",
            getSms: true,
            optOut: false,
            noEmail: false,
            getBilling: true,
            getMarketing: false,
            getReports: true,
            refCustomerId: 0,
            referredBy: "",
            taxRateId: 0,
            notificationEmail: email,
            invoiceCcEmails: "",
            invoiceTermId: 0,
            properties: [:],
            consent: [:]
        )
        
        do {
            let data = try await NetworkService.shared.createCustomer(customerInfo)
            if let responseString = String(data: data, encoding: .utf8) {
                if let customerId = decodeCustomerID(jsonString: responseString) {
                    self.createdCustomerId = customerId
                    self.customerCreated = true
                }
            }
        } catch {
            showError(error.localizedDescription)
        }
        
        stopLoading()
    }
}

