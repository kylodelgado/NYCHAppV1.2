//
//  SubmitTicketView.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/22/24.
//

import SwiftUI

struct SubmitCustomerInfoView: View {
    
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
    @State var customerID: Int?
    

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    
                    TextFields(text: $firstName, topText: "First Name *")
                    TextFields(text: $lastName, topText: "Last Name *")
                    TextFields(text: $businessName, topText: "Business Name")
                    
                    TextFields(text: $phone, topText: "Phone Number *")
                        .onChange(of: phone) { oldValue, newValue in
                        phone = newValue.filter { $0.isNumber }
                    }.keyboardType(.phonePad)
                    
                    TextFields(text: $email, topText: "Email Address *").keyboardType(.emailAddress)
                    
                    TextFields(text: $addressNumber, topText: "Address")
                    
                    
                    HStack {
                        TextFields(text: $city, topText: "City").frame(minWidth: 190)
                        Pickers(topText: "State", pickFrom: $states , selection: $state).padding(.horizontal, -30)
                        TextFields(text: $zipCode, topText: "Zipcode").onChange(of: zipCode){oldValue, newValue in
                            zipCode = newValue.filter { $0.isNumber }
                            
                        }
                            .keyboardType(.numberPad)
                        
                    }
                    Button {
                        
                        if firstName != "" || lastName != "" || email != "" || phone != "" {
                            
                            let newCustomer = CustomerInfo(businessName: businessName, firstname: firstName, lastname: lastName, email: email, phone: phone, mobile: "", address: addressNumber, address2: "", city: city, state: state, zip: zipCode, notes: "", getSms: true, optOut: true, noEmail: true, getBilling: true, getMarketing: true, getReports: true, refCustomerId: 0, referredBy: "", taxRateId: 0, notificationEmail: email, invoiceCcEmails: "", invoiceTermId: 0, properties: [:], consent: [:])
                        
                            createCustomer(customer: newCustomer) { result in
                                switch result {
                                case .success(let data):
                                    // Handle successful response
                                    if let responseString = String(data: data, encoding: .utf8) {
                                        print((responseString))
                                        
                                        customerID = decodeCustomerID(jsonString: responseString)
                                        
                                        
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
                
        
                .navigationDestination(isPresented: $ticketInfoSheet) {
                    
                    if customerID != nil {
                        SubmitTicketInfoView(customerID: customerID!)
                    }
                    
                }
                   
                }
             
                
               
            
            .navigationTitle("Customer Information")
            
            
            
        }
        
        
      
    }
    
    func validateInputs() {
        // code here
    }
}

#Preview {

    
    SubmitCustomerInfoView(firstName: "", lastName: "", businessName: "", email: "", phone: "", addressNumber: "", city: "", zipCode: "")
}



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
        case firstname
        case lastname
        case email
        case phone
        case mobile
        case address
        case address2 = "address_2"
        case city
        case state
        case zip
        case notes
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
        case properties
        case consent
    }
}

struct TextFields: View {
    @Binding var text: String
    @State var topText: String
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(topText)
                .font(.caption)
                .foregroundColor(.black)
                .offset(y: 5)
                .padding(.horizontal)
            
            TextField("", text: $text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1.5)
                        .fill(.blue.gradient).opacity(0.5)
                        
                )
                .padding(.horizontal)
            }
       
        }
    }

struct Pickers: View {
    @State var topText: String
    @Binding var pickFrom : [String]
    @Binding var selection : String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(topText)
                .font(.caption)
                .foregroundColor(.black)
                .offset(y: 5)
                .padding(.horizontal)
            
            Picker("Selection", selection: $selection) {
                ForEach(pickFrom, id: \.self) { pick in
                    Text(pick)
                }
            }
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1.5)
                        .fill(.blue.gradient).opacity(0.5)
                        
                )
                .padding(.horizontal)
            }
       
        }
    }

struct States {
    static let states = [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming",
        "DC": "District of Columbia"
    ]
    
    let stateAbbreviations = Array(states.keys).sorted()
    let stateNames = Array(states.values).sorted()
}


func createCustomer(customer: CustomerInfo, completion: @escaping (Result<Data, Error>) -> Void) {
    // API endpoint
    let urlString = "https://nych.repairshopr.com/api/v1/customers"
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Add headers
    request.addValue("application/json", forHTTPHeaderField: "accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("T5b51cee4f21d46aaa-b7650daffe9eb74b1ffdccc3a01abe40", forHTTPHeaderField: "Authorization")
    
    // Encode the customer data
    do {
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(customer)
    } catch {
        completion(.failure(error))
        return
    }
    
    // Create and start the network task
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            
            return
        }
        
        completion(.success(data))
        
    }
    
    task.resume()
}




struct CustomerIDResponse: Codable {
    let customer: CustomerID
}

struct CustomerID: Codable {
    let id: Int
}
func decodeCustomerID(jsonString: String) -> Int? {
    // Remove "Success: " to isolate JSON
    guard let jsonData = jsonString
            .data(using: .utf8) else {
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


