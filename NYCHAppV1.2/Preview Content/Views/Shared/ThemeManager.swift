//
//  ThemeManager.swift
//  NYCHAppV1.2
//
//  Created by Brandon Delgado on 12/28/24.
//

import SwiftUI

struct AppTheme {
    static let primaryColor = Color.blue
    static let secondaryColor = Color.gray
    static let backgroundColor = Color(.systemBackground)
    static let accentColor = Color.blue.opacity(0.8)
    
    static let titleFont = Font.system(.title, design: .rounded).weight(.semibold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    
    static let cardBackground = Color(.systemBackground)
    static let cardShadow = Color.black.opacity(0.1)
}
