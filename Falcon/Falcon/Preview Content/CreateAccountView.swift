
//
//  CreateAccountView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//  Updated 4/18/25 – removed searchable state search bar
//

import SwiftUI
import Firebase
import FirebaseAuth

struct CreateAccountView: View {

    // MARK: ‑‑ Helpers and Validators
    struct AccountValidator {
        private static let emailPattern =
          #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        static func isValidEmail(_ email: String) -> Bool {
            let regex = try! NSRegularExpression(pattern: emailPattern)
            let range = NSRange(email.startIndex..<email.endIndex, in: email)
            return regex.firstMatch(in: email, range: range) != nil
        }
        static func countUppercase(in s: String) -> Int {
            s.filter { $0.isUppercase }.count
        }
        static func countSpecial(in s: String) -> Int {
            let specials = CharacterSet(charactersIn: "!@#$%^&*()-_?<>")
            return s.unicodeScalars.filter { specials.contains($0) }.count
        }
        static func passwordRules(_ s: String)
            -> (minOK: Bool, upOK: Bool, specOK: Bool)
        {
            (s.count >= 8,
             countUppercase(in: s) >= 2,
             countSpecial(in: s) >= 2)
        }
        static func passwordStrength(_ s: String) -> Int {
            let r = passwordRules(s)
            return [r.minOK, r.upOK, r.specOK].filter { $0 }.count
        }
    }

    // Email lookup states
    enum EmailStatus { case unknown, checking, available, taken, error }

    // Validation Computeds
    var firstNameValid: Bool { firstName.count >= 2 && firstName.count <= 50 }
    var lastNameValid:  Bool { lastName.count >= 2 && lastName.count <= 50 }
    var cityValid:      Bool { !city.trimmingCharacters(in: .whitespaces).isEmpty && city.count <= 50 }
    var emailFormatValid: Bool {
        AccountValidator.isValidEmail(email.lowercased()) && email.count <= 50
    }
    var zipValid: Bool { zipCode.isEmpty || zipCode.count <= 10 }
    var orgNameValid: Bool {
        orgAction == .none ||
        (!organizationName.trimmingCharacters(in: .whitespaces).isEmpty &&
         organizationName.count <= 50)
    }
    var stateValid: Bool { !locationManager.selectedState.isEmpty }
    var pwRules: (minOK: Bool, upOK: Bool, specOK: Bool) {
        AccountValidator.passwordRules(password)
    }
    var passwordTooLong: Bool { password.count > 15 }
    var passwordValid: Bool {
        pwRules.minOK && pwRules.upOK && pwRules.specOK && !passwordTooLong
    }
    var isFormValid: Bool {
        firstNameValid && lastNameValid &&
        stateValid && cityValid &&
        emailFormatValid && emailStatus == .available &&
        zipValid && orgNameValid &&
        passwordValid
    }

    // State
    @StateObject private var locationManager = LocationManager()

    // Form fields
    @State private var firstName = ""
    @State private var middleName = ""
    @State private var lastName = ""
    @State private var city = ""
    @State private var zipCode = ""
    @State private var email = ""
    @State private var password = ""
    @State private var organizationName = ""
    @State private var orgAction: OrgAction = .none
    @State private var selectedRole = "tech"
    @State private var isShowingSearch = false
    @State private var isShowingCreate = false
    @State private var organizationId: String?
    let availableRoles = ["tech", "admin"]

    // UI states
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var emailStatus: EmailStatus = .unknown
    @State private var emailDebounceWorkItem: DispatchWorkItem?

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
                    ProgressView("Creating account…").padding()
                }

                Form {
                    nameSection
                    locationSection
                    credentialsSection
                    organizationSection

                    if let errorMessage = errorMessage {
                        Section {
                            Text(errorMessage).foregroundColor(.red)
                        }
                    }
                }

                VStack(spacing: 20) {
                    Button("Cancel") { dismiss() }
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.red).foregroundColor(.white)
                        .cornerRadius(10).padding(.horizontal)

                    Button("Save", action: registerUser)
                        .frame(maxWidth: .infinity).padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10).padding(.horizontal)
                        .disabled(!isFormValid)
                }
                .padding(.vertical)
            }
            .navigationTitle("Create Account")
            .onChange(of: email) { newEmail in
                emailStatus = .unknown
                emailDebounceWorkItem?.cancel()
                let workItem = DispatchWorkItem {
                    checkEmailAvailability(email: newEmail.lowercased())
                }
                emailDebounceWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
            }
        }
    }

    private var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("First Name", text: $firstName)
            if !firstNameValid && !firstName.isEmpty {
                errorText("First name must be 2–50 characters")
            }
            TextField("Middle Name (optional)", text: $middleName)
            TextField("Last Name", text: $lastName)
            if !lastNameValid && !lastName.isEmpty {
                errorText("Last name must be 2–50 characters")
            }
        }
    }

    private var locationSection: some View {
        Section(header: Text("Location")) {
            // State picker
            Picker("State", selection: $locationManager.selectedState) {
                ForEach(locationManager.states, id: \.self) {
                    Text($0)
                }
            }
            if !stateValid {
                errorText("Please select a state")
            }

            // City
            TextField("City", text: $city)
                .disabled(!stateValid)
                .autocapitalization(.words)
                .onSubmit {
                    city = city.trimmingCharacters(in: .whitespaces)
                    if !city.isEmpty {
                        city = city.prefix(1).uppercased() + city.dropFirst()
                    }
                }
            if !cityValid && !city.isEmpty {
                errorText("City must be 1–50 characters")
            }
        }
    }

    private var credentialsSection: some View {
        Section(header: Text("Credentials")) {
            TextField("Email", text: $email)
            emailFeedbackView
            SecureField("Password", text: $password)
            if passwordTooLong {
                errorText("Password must be 15 characters or less")
            }
            let strength = AccountValidator.passwordStrength(password)
            HStack {
                Text("Strength:")
                ProgressView(value: Double(strength), total: 3)
                Text(strength == 3 && password.count == 15 ? "Strong"
                     : strength >= 2 ? "Medium" : "Weak")
            }
            VStack(alignment: .leading, spacing: 4) {
                ruleRow("8+ characters", pwRules.minOK)
                ruleRow("2 uppercase", pwRules.upOK)
                ruleRow("2 special chars", pwRules.specOK)
            }
            if passwordValid {
                Text("✓ Password meets all requirements")
            }
        }
    }

    private var organizationSection: some View {
        Section(header: Text("Organization (Optional)")) {
            // Choose join or create
            Picker("Action", selection: $orgAction) {
                ForEach(OrgAction.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if orgAction != .none {
                // Org name + action button
                HStack {
                    TextField("Organization Name", text: $organizationName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        if orgAction == .join {
                            isShowingSearch = true
                        } else {
                            isShowingCreate = true
                        }
                    }) {
                        Text(orgAction == .join ? "Search" : "Create")
                    }
                    .disabled(
                        organizationName.trimmingCharacters(in: .whitespaces).count < 2 ||
                        organizationName.count > 50
                    )
                }
                .padding(.vertical, 4)
                
                // Inline validation
                if organizationName.trimmingCharacters(in: .whitespaces).count < 2,
                   !organizationName.isEmpty {
                    errorText("Name must be at least 2 characters")
                } else if organizationName.count > 50 {
                    errorText("Name must be 50 characters or less")
                }
                
                // Only show role picker on join
                if orgAction == .join {
                    Picker("Select Role", selection: $selectedRole) {
                        ForEach(availableRoles, id: \.self) {
                            Text($0.capitalized)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
        // Join overlay
        .sheet(isPresented: $isShowingSearch) {
            OrgSearchOverlay(
                query: $organizationName,
                selectedOrgID: $organizationId
            )
        }
        // Create overlay (placeholder)
        .sheet(isPresented: $isShowingCreate) {
            CreateOrganizationView(
                name: organizationName,
                onCreated: { newID in
                    organizationId = newID
                    isShowingCreate = false
                }
            )
        }
    }

    @ViewBuilder
    private var emailFeedbackView: some View {
        if !emailFormatValid && !email.isEmpty {
            errorText("Enter valid email (≤50 chars)")
        } else {
            switch emailStatus {
            case .checking:
                HStack {
                    ProgressView()
                    Text("Checking availability…")
                }
            case .taken:
                errorText("Email already registered")
            case .available:
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Email available")
                }
            case .error:
                Text("Could not verify email")
            default:
                EmptyView()
            }
        }
    }

    private func ruleRow(_ text: String, _ passed: Bool) -> some View {
        Label(text, systemImage: passed ? "checkmark.circle" : "xmark.circle")
    }
    private func errorText(_ msg: String) -> some View {
        Text(msg).foregroundColor(.red)
    }

    private func checkEmailAvailability(email: String) {
        guard emailFormatValid else { return }
        emailStatus = .checking
        Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
            if let _ = error {
                emailStatus = .error
            } else if let methods, !methods.isEmpty {
                emailStatus = .taken
            } else {
                emailStatus = .available
            }
        }
    }


    // MARK: ‑‑ Registration
    private func registerUser() {
        guard emailStatus == .available else { return }
        isLoading = true; errorMessage = nil

        Auth.auth().createUser(withEmail: email.lowercased(), password: password) { authResult, err in
            if let err {
                isLoading = false
                errorMessage = "Account creation failed: \\(err.localizedDescription)"
                return
            }
            guard let uid = authResult?.user.uid else {
                isLoading = false
                errorMessage = "Failed to obtain user ID."
                return
            }
            let pending = (orgAction != .none && selectedRole == "admin")
            let newUser = User(
                id: uid,
                firstName: firstName,
                middleName: middleName.isEmpty ? nil : middleName,
                lastName: lastName,
                email: email.lowercased(),
                city: city,
                state: locationManager.selectedState,
                zipCode: zipCode.isEmpty ? nil : zipCode,
                organizationId: (orgAction != .none ? "placeholder_org_id" : nil),
                organizationName: (orgAction != .none ? organizationName : nil),
                role: (orgAction != .none ? selectedRole : nil),
                pendingApproval: pending,
                isOrgAdmin: (orgAction == .create),
                profilePictureURL: nil,
                createdAt: Date()
            )
            FirestoreManager.shared.createUser(user: newUser) { result in
                isLoading = false
                switch result {
                case .success(): dismiss()
                case .failure(let fErr):
                    errorMessage = "Failed to save user: \\(fErr.localizedDescription)"
                }
            }
        }
    }
}

// Preview
#Preview {
    CreateAccountView()
}
