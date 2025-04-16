//
//  CreateAccountView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//


import SwiftUI
import Firebase
import FirebaseAuth

struct CreateAccountView: View {
    // Basic profile fields
    @State private var firstName = ""
    @State private var middleName = ""
    @State private var lastName = ""
    
    // Location details
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    
    // Credentials
    @State private var email = ""
    @State private var password = ""
    
    // Organization related fields
    @State private var organizationName = ""
    @State private var orgAction: OrgAction = .none // none, join, or create
    @State private var selectedRole = "tech"  // default role when joining an org
    let availableRoles = ["tech", "admin"]
    
    // UI State Handling
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) private var dismiss
    
    enum OrgAction: String, CaseIterable {
        case none = "None"
        case join = "Join Organization"
        case create = "Create Organization"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Creating account...")
                        .padding()
                }
                
                Form {
                    // MARK: Name Section
                    Section(header: Text("Name")) {
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                        TextField("Middle Name (optional)", text: $middleName)
                            .textContentType(.middleName)
                        TextField("Last Name", text: $lastName)
                            .textContentType(.familyName)
                    }
                    
                    // MARK: Location Section
                    Section(header: Text("Location")) {
                        TextField("City", text: $city)
                            .textContentType(.addressCity)
                        TextField("State", text: $state)
                            .textContentType(.addressState)
                        TextField("Zip Code (optional)", text: $zipCode)
                            .keyboardType(.numberPad)
                    }
                    
                    // MARK: Credentials Section
                    Section(header: Text("Credentials")) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                    }
                    
                    // MARK: Organization Section
                    Section(header: Text("Organization (Optional)")) {
                        Picker("Organization Action", selection: $orgAction) {
                            ForEach(OrgAction.allCases, id: \.self) { action in
                                Text(action.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if orgAction != .none {
                            TextField("Organization Name", text: $organizationName)
                                .autocapitalization(.words)
                            
                            Picker("Select Role", selection: $selectedRole) {
                                ForEach(availableRoles, id: \.self) { role in
                                    Text(role.capitalized)
                                }
                            }
                        }
                    }
                    
                    // MARK: Error Message Display
                    if let errorMessage = errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                VStack(spacing: 20) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: registerUser) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Create Account")
        }
    }
    
    /// Handles account creation via FirebaseAuth then stores additional user data.
    func registerUser() {
        // Optional: Validate fields here
        
        isLoading = true
        errorMessage = nil
        
        // Create the user with FirebaseAuth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                isLoading = false
                errorMessage = "Account creation failed: \(error.localizedDescription)"
                return
            }
            
            guard let uid = authResult?.user.uid else {
                isLoading = false
                errorMessage = "Failed to obtain user ID."
                return
            }
            
            // Determine pending approval based on organization settings
            let pending = (orgAction != .none && selectedRole == "admin")
            
            // Construct the user object based on the updated model
            let newUser = User(
                id: uid,
                firstName: firstName,
                middleName: middleName.isEmpty ? nil : middleName,
                lastName: lastName,
                email: email,
                city: city,
                state: state,
                zipCode: zipCode.isEmpty ? nil : zipCode,
                organizationId: (orgAction != .none ? "placeholder_org_id" : nil),
                organizationName: (orgAction != .none ? organizationName : nil),
                role: (orgAction != .none ? selectedRole : nil),
                pendingApproval: pending,
                isOrgAdmin: (orgAction == .create),
                profilePictureURL: nil,
                createdAt: Date()
            )
            
            // Save user data to Firestore using FirestoreManager
            FirestoreManager.shared.createUser(user: newUser) { result in
                isLoading = false
                switch result {
                case .success():
                    print("User successfully created and stored.")
                    dismiss()
                case .failure(let error):
                    errorMessage = "Failed to save user data: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
