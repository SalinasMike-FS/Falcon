//
//  User.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import Foundation
import UIKit
import SwiftUI


struct User : Identifiable{
    var id: ObjectIdentifier
    let firstName: String
    var middleName: String?
    let lastName: String
    let city: String
    let state: String
    let email: String
    let password: String
    
    
    
    
}
