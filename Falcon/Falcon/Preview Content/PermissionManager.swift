//
//  PermissionManager.swift
//  Falcon
//
//  Created by Natividad Michael Salinas II on 4/18/25.
//
//  Provides centralized permission checking.
//

import Foundation

class PermissionManager {
    static let shared = PermissionManager()

    private let systemSuperAdmins: Set<String> = ["your_firebase_uid_here"]

    func userHasPermission(_ permission: Permission, for user: User) -> Bool {
        if systemSuperAdmins.contains(user.id) {
            return true
        }
        return RolePermissions[user.role ?? ""]?.contains(permission) ?? false
    }

    func permissions(for user: User) -> [Permission] {
        if systemSuperAdmins.contains(user.id) {
            return Permission.allCases
        }
        return RolePermissions[user.role ?? ""] ?? []
    }
}
