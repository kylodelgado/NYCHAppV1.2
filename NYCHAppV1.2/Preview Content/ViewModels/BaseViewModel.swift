//
//  BaseViewModel.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.hasError = true
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
            self.hasError = false
        }
    }
}
