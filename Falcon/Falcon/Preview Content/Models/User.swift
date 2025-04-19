//
//  User.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    // Unique identifier matching the Firebase UID
    var id: String
    
    // Basic user details
    let firstName: String
    var middleName: String?
    let lastName: String
    let email: String
    let city: String
    let state: String
    var zipCode: String? // Optional demographic info
    
    // Organizational details
    var organizationId: String?      // The organization's unique identifier
    var organizationName: String?    // The display name of the organization
    var role: String?                // Role within the organization (e.g., "admin", "tech")
    var pendingApproval: Bool        // Indicates if an admin approval is pending
    var isOrgAdmin: Bool             // True if the user is the primary organization admin
    
    // Profile and creation info
    var profilePictureURL: String?   // Optional URL for the profile image
    let createdAt: Date              // The date the account was created
}
