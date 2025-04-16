//
//  FirestoreManager.swift
//  Falcon
//
//  Created by Natividad Michael Salinas II on 4/16/25.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth



/// A singleton class to manage Firestore operations efficiently.
class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    
    /// In-memory cache for data that changes infrequently.
    private var cache: [String: Any] = [:]
    
    /// Interval (in seconds) to refresh cache (adjust as needed).
    private let cacheExpiration: TimeInterval = 300 // 5 minutes
    
    /// Timestamps for cache entries.
    private var cacheTimestamps: [String: Date] = [:]
    
    private init() {}
    
    // MARK: - Caching Helpers

    /// Checks the cache for a given key. Returns nil if the cache is stale.
    func getCachedValue(for key: String) -> Any? {
        if let timestamp = cacheTimestamps[key],
           Date().timeIntervalSince(timestamp) < cacheExpiration {
            return cache[key]
        }
        return nil
    }
    
    /// Stores a value in the cache with the current timestamp.
    func setCache(value: Any, for key: String) {
        cache[key] = value
        cacheTimestamps[key] = Date()
    }
    
    // MARK: - User Management

    /// Saves a new user to the "users" collection.
    func createUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use the Firebase UID as documentID
        let userRef = db.collection("users").document(user.id)
        
        do {
            try userRef.setData(from: user) { error in
                if let error = error {
                    print("Error saving user: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("User saved successfully")
                    completion(.success(()))
                }
            }
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    /// Fetches a user from Firestore
    func fetchUser(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        let docRef = db.collection("users").document(userID)
        
        // Check cache first to reduce reads
        if let cached = getCachedValue(for: userID) as? User {
            completion(.success(cached))
            return
        }
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    // Cache the fetched user
                    self.setCache(value: user, for: userID)
                    completion(.success(user))
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "FirestoreManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Batch Write Operations

    /// Performs a batched write for an array of document updates.
    func batchWriteDocuments(collection: String, documents: [(documentID: String, data: [String: Any])], completion: @escaping (Result<Void, Error>) -> Void) {
        let batch = db.batch()
        let collRef = db.collection(collection)
        
        for doc in documents {
            let docRef = collRef.document(doc.documentID)
            batch.setData(doc.data, forDocument: docRef, merge: true)
        }
        
        batch.commit { error in
            if let error = error {
                print("Batch write failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Batch write succeeded")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Master Documents Management
    
    /// Updates or creates a master document that aggregates summary data.
    func updateMasterDocument(documentID: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        let masterDocRef = db.collection("masters").document(documentID)
        masterDocRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating master document: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Master document updated successfully")
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Additional Methods
    /// Example: Fetching roles for an organization (to minimize calls, consider caching these too)
    func fetchOrganizationRoles(organizationID: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let rolesDocRef = db.collection("organizations").document(organizationID)
        let cacheKey = "orgRoles-\(organizationID)"
        
        if let cachedRoles = getCachedValue(for: cacheKey) as? [String] {
            completion(.success(cachedRoles))
            return
        }
        
        rolesDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching organization roles: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let document = document, document.exists,
               let data = document.data(),
               let roles = data["roles"] as? [String] {
                self.setCache(value: roles, for: cacheKey)
                completion(.success(roles))
            } else {
                let error = NSError(domain: "FirestoreManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Roles not found"])
                completion(.failure(error))
            }
        }
    }
}
