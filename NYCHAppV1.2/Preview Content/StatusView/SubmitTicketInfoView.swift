//
//  SubmitTicketInfoView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/23/24.
//

import SwiftUI

struct SubmitTicketInfoView: View {
    
    @State var customerID: Int
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var businessName: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var addressNumber : String = ""
    @State var city: String = ""
    @State var state: String = "NY"
    @State var zipCode: String = ""
    @State var ticketInfoSheet: Bool = false
    @State var states = States().stateAbbreviations
    

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    
         
                    
                    
                    
                    TextFields(text: $city, topText: "\(customerID)")
                     
                  
                    }
                
                
                    Button {
                        
                        if firstName != "" || lastName != "" || email != "" || phone != "" {
                            
                            let newCustomer = CustomerInfo(businessName: businessName, firstname: firstName, lastname: lastName, email: email, phone: phone, mobile: "", address: addressNumber, address2: "", city: city, state: state, zip: zipCode, notes: "", getSms: true, optOut: true, noEmail: true, getBilling: true, getMarketing: true, getReports: true, refCustomerId: 0, referredBy: "", taxRateId: 0, notificationEmail: email, invoiceCcEmails: "", invoiceTermId: 0, properties: [:], consent: [:])
                        
                            createCustomer(customer: newCustomer) { result in
                                switch result {
                                case .success(let data):
                                    // Handle successful response
                                    if let responseString = String(data: data, encoding: .utf8) {
                                        print("Success: \(responseString)")
                                        ticketInfoSheet.toggle()
                                    }
                                case .failure(let error):
                                    // Handle error
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            print("Something went wrong")
                        }
                        
                    } label: {
                        
                        NewButton(textToShow: "Create Customer")
                          
                    }.padding(.vertical)
                    
                    
                    
                }
                .containerRelativeFrame(.horizontal){width, axis in
                    width * 1
                    
                }
                .navigationTitle("CustomerID \(String(customerID))")
                 
                }
             
                
               
            
           
            
            
            
        }
        
        
      
    }
    
    func validateInputs() {
        // code here
    
}


#Preview {
    SubmitTicketInfoView(customerID: 33017418)
}
