//
//  Untitled.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

class TicketViewModel: BaseViewModel {
    // Customer Info
    let customerID: Int
    let customerName: String
    
    // Form Data
    @Published var deviceType = ""
    @Published var issue = ""
    @Published var devicePassword = ""
    @Published var droppingCharger = false
    @Published var droppingHandTruck = false
    @Published var droppingSleeve = false
    @Published var droppingBag = false
    @Published var droppingSomethingElse = false
    @Published var whatElseIsDropping = ""
    @Published var areFilesImportant = false
    @Published var hasbitlocker = false
    @Published var bitlockerKey = ""
    @Published var isDeviceOnWarranty = false
    @Published var issueDescription = ""
    
    // Form State
    @Published var hasAttemptedSubmission = false
    @Published var ticketCreated = false
    @Published var createdTicketNumber: String?
    
    init(customerID: Int, customerName: String) {
        self.customerID = customerID
        self.customerName = customerName
        super.init()
    }
    
    var isFormValid: Bool {
        !deviceType.isEmpty &&
        !issue.isEmpty &&
        !issueDescription.isEmpty &&
        (!droppingSomethingElse || (droppingSomethingElse && !whatElseIsDropping.isEmpty)) &&
        (!hasbitlocker || (hasbitlocker && !bitlockerKey.isEmpty))
    }
    
    func validateForm() -> Bool {
        hasAttemptedSubmission = true
        
        if deviceType.isEmpty {
            showError("Please enter device type")
            return false
        }
        if issue.isEmpty {
            showError("Please describe the issue")
            return false
        }
        if issueDescription.isEmpty {
            showError("Please provide issue description")
            return false
        }
        if droppingSomethingElse && whatElseIsDropping.isEmpty {
            showError("Please specify what else you're dropping off")
            return false
        }
        if hasbitlocker && bitlockerKey.isEmpty {
            showError("Please provide Bitlocker key")
            return false
        }
        return true
    }
    
    @MainActor
    func createTicket() async {
        guard validateForm() else { return }
        
        startLoading()
        
        let ticket = TicketItem(
            customerId: customerID,
            subject: "\(deviceType) - \(issue)",
            status: "New",
            properties: [
                "Bag": droppingBag ? "1" : "0",
                "Charger": droppingCharger ? "1" : "0",
                "Hand Truck": droppingHandTruck ? "1" : "0",
                "Laptop Sleeve": droppingSleeve ? "1" : "0",
                "Also dropping off": droppingSomethingElse ? whatElseIsDropping : "",
                "Are files important": areFilesImportant ? "YES" : "NO",
                "Is device under warranty": isDeviceOnWarranty ? "1" : "0",
                "Bitlocker key": hasbitlocker ? bitlockerKey : "",
                "Device Password": devicePassword
            ],
            commentsAttributes: [
                Comment(
                    subject: "Issue Description",
                    body: issueDescription,
                    hidden: true,
                    tech: customerName
                )
            ]
        )
        
        do {
            let data = try await NetworkService.shared.createTicket(ticket)
            if let responseString = String(data: data, encoding: .utf8) {
                print("Success: \(responseString)")
                self.ticketCreated = true
            }
        } catch {
            showError(error.localizedDescription)
        }
        
        stopLoading()
    }
}
