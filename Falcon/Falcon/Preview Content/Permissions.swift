
//
//  Permissions.swift
//  Falcon
//
//  Created by Natividad Michael Salinas II on 4/18/25.
//
//  Defines all role-based permissions in the system.
//

import Foundation

enum Permission: String, CaseIterable {
    case addUser
    case editWarehouse
    case assignVehicle
    case viewMap
    case useInventory
    case assignTechs
    case viewAssignedJobs
    case viewAssignedTech
    case trackVehicle
    case createJob
    case manageRoles
    case accessSettings

    var label: String {
        switch self {
        case .addUser: return "Add Users"
        case .editWarehouse: return "Edit Warehouse"
        case .assignVehicle: return "Assign Vehicles"
        case .viewMap: return "View Fleet Map"
        case .useInventory: return "Use Inventory"
        case .assignTechs: return "Assign Techs"
        case .viewAssignedJobs: return "View Assigned Jobs"
        case .viewAssignedTech: return "View Assigned Tech"
        case .trackVehicle: return "Track Vehicle"
        case .createJob: return "Create Job"
        case .manageRoles: return "Manage Roles"
        case .accessSettings: return "Access Settings"
        }
    }
}

let RolePermissions: [String: [Permission]] = [
    "admin": Permission.allCases,
    "manager": [
        .addUser, .assignVehicle, .viewMap,
        .editWarehouse, .useInventory, .viewAssignedJobs
    ],
    "dispatcher": [
        .assignTechs, .createJob, .viewMap
    ],
    "tech": [
        .useInventory, .viewAssignedJobs
    ],
    "customer": [
        .viewAssignedTech, .trackVehicle
    ]
]

func userHasPermission(_ permission: Permission, for user: User) -> Bool {
    let superAdmins: Set<String> = ["your_firebase_uid_here"]
    if superAdmins.contains(user.id) {
        return true
    }
    return RolePermissions[user.role ?? ""]?.contains(permission) ?? false
}

func permissions(for user: User) -> [Permission] {
    let superAdmins: Set<String> = ["your_firebase_uid_here"]
    if superAdmins.contains(user.id) {
        return Permission.allCases
    }
    return RolePermissions[user.role ?? ""] ?? []
}
