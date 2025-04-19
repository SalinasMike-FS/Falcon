//
//  CatalogItem.swift
//  Falcon
//
//  Created by Natividad Michael Salinas II on 4/16/25.
//
import Foundation
import UIKit
import SwiftUI

struct CatalogItem: Identifiable, Codable {
    let id: UUID
    var name: String // mandatory
    
    var distributor: String?
    var imageURL: String? // or UIImage if local
    var weight: Double?
    var manufacturer: String?
    var wholesalePrice: Double?
    var retailPrice: Double?
    var category: ItemCategory?
    var dateAdded: Date
    var addedBy: String // user ID or username
}

enum ItemCategory: String, Codable, CaseIterable {
    case tools = "Tools"
    case parts = "Parts"
    case supplies = "Supplies"
    // Add additional categories or nested subcategories as needed
}
