//
//  ExistingCustomerViewModel.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/31/24.
//

import Foundation

@MainActor
class ExistingCustomerViewModel: BaseViewModel {
    @Published var searchText = ""
    @Published var searchType = "Phone"
    @Published var foundCustomerId: Int?
    @Published var foundCustomerName: String?
    @Published var validationMessage: String?
    
    var isInputValid: Bool {
        if searchText.isEmpty { return false }
        
        if searchType == "Phone" {
            return searchText.count >= 10
        } else {
            return searchText.contains("@") && searchText.contains(".")
        }
    }
    
    func validateInput() -> Bool {
        validationMessage = nil
        
        if searchText.isEmpty {
            validationMessage = "Please enter a \(searchType.lowercased())"
            return false
        }
        
        if searchType == "Phone" {
            if searchText.count < 10 {
                validationMessage = "Please enter a valid phone number"
                return false
            }
        } else {
            if !searchText.contains("@") || !searchText.contains(".") {
                validationMessage = "Please enter a valid email address"
                return false
            }
        }
        
        return true
    }
    func searchCustomer() async {
        guard !searchText.isEmpty else {
            showError("Please enter a search term")
            return
        }
        
        print("Debug: Starting customer search with type: \(searchType), term: \(searchText)")
        startLoading()
        
        do {
            if searchType == "Phone" {
                print("Debug: Performing phone search")
                let response = try await NetworkService.shared.searchCustomerByPhone(searchText)
                if let result = response.results.first {
                    foundCustomerId = result.table._id
                    let details = result.table._source.table
                    foundCustomerName = "\(details.firstname) \(details.lastname)"
                    print("Debug: Found customer by phone: \(foundCustomerName ?? "nil")")
                } else {
                    print("Debug: No customer found with phone number")
                    showError("No customer found with this phone number")
                }
            } else {
                print("Debug: Performing email search")
                let response = try await NetworkService.shared.searchCustomerByEmail(searchText)
                if let customer = response.customers.first {
                    foundCustomerId = customer.id
                    foundCustomerName = customer.fullname
                    print("Debug: Found customer by email: \(foundCustomerName ?? "nil")")
                } else {
                    print("Debug: No customer found with email")
                    showError("No customer found with this email")
                }
            }
        } catch {
            print("Debug: Search error: \(error)")
            showError(error.localizedDescription)
        }
        
        stopLoading()
    }
}
