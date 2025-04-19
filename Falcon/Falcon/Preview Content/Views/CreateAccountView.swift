
//  CreateAccountView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//  Updated 4/19/25 – removed PrimaryButtonStyle, inlined button styling.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccountView: View {

    // MARK: – Validation Helpers
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
            let rules = passwordRules(s)
            return [rules.minOK, rules.upOK, rules.specOK].filter { $0 }.count
        }
    }

    enum EmailStatus { case unknown, checking, available, taken, error }

    // MARK: – Form State
    @StateObject private var locationManager = LocationManager()
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
    let availableRoles = ["tech", "admin"]

    // MARK: – UI & Validation State
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var emailStatus: EmailStatus = .unknown
    @State private var emailDebounceWorkItem: DispatchWorkItem?

    // MARK: – Sheet Control
    enum ActiveSheet: Identifiable {
        case search, create
        var id: Int { hashValue }
    }
    @State private var activeSheet: ActiveSheet?
    @State private var organizationId: String?

    @Environment(\.dismiss) private var dismiss

    enum OrgAction: String, CaseIterable {
        case none = "None"
        case join = "Join Organization"
        case create = "Create Organization"
    }

    // MARK: – Validation Computeds
    var firstNameValid: Bool { firstName.count >= 2 && firstName.count <= 50 }
    var lastNameValid:  Bool { lastName.count >= 2 && lastName.count <= 50 }
    var cityValid:      Bool { !city.trimmingCharacters(in: .whitespaces).isEmpty && city.count <= 50 }
    var stateValid:     Bool { !locationManager.selectedState.isEmpty }
    var emailValid: Bool {
        AccountValidator.isValidEmail(email.lowercased()) && email.count <= 50 && emailStatus == .available
    }
    var zipValid: Bool { zipCode.isEmpty || zipCode.count <= 10 }
    var orgNameValid: Bool {
        organizationName.trimmingCharacters(in: .whitespaces).count >= 2 &&
        organizationName.count <= 50
    }
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
        emailValid && zipValid &&
        passwordValid &&
        (orgAction == .none || orgNameValid)
    }

    // MARK: – Body
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

                    if let msg = errorMessage {
                        Section { Text(msg).foregroundColor(.red) }
                    }
                }
                actionButtons
            }
            .navigationTitle("Create Account")
            .onChange(of: email) { newEmail in
                debounceEmailCheck(newEmail)
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .search:
                    OrgSearchOverlay(query: $organizationName,
                                     selectedOrgID: $organizationId)
                case .create:
                    CreateOrganizationView(name: organizationName) { newID in
                        organizationId = newID
                        activeSheet = nil
                    }
                }
            }
        }
    }

    // MARK: – Sections
    private var nameSection: some View {
        Section("Name") {
            TextField("First Name", text: $firstName)
            if !firstNameValid && !firstName.isEmpty {
                errorText("First name 2–50 chars")
            }
            TextField("Middle Name (optional)", text: $middleName)
            TextField("Last Name", text: $lastName)
            if !lastNameValid && !lastName.isEmpty {
                errorText("Last name 2–50 chars")
            }
        }
    }

    private var locationSection: some View {
        Section("Location") {
            Picker("State", selection: $locationManager.selectedState) {
                ForEach(locationManager.states, id: \.self) { Text($0) }
            }
            if !stateValid { errorText("Please select a state") }

            TextField("City", text: $city)
                .disabled(!stateValid)
                .autocapitalization(.words)
            if !cityValid && !city.isEmpty {
                errorText("City 1–50 chars")
            }
        }
    }

    private var credentialsSection: some View {
        Section("Credentials") {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            emailFeedbackView

            SecureField("Password", text: $password)
            if passwordTooLong { errorText("Password ≤15 chars") }

            let strength = AccountValidator.passwordStrength(password)
            HStack {
                Text("Strength:")
                ProgressView(value: Double(strength), total: 3)
                Text(strength == 3 && password.count == 15 ? "Strong" : strength >= 2 ? "Medium" : "Weak")
            }
            VStack(alignment: .leading, spacing: 4) {
                ruleRow("8+ chars", pwRules.minOK)
                ruleRow("2 uppercase", pwRules.upOK)
                ruleRow("2 special", pwRules.specOK)
            }
            if passwordValid {
                Text("✓ Password meets requirements").foregroundColor(.green)
            }
        }
    }

    private var organizationSection: some View {
        Section("Organization (Optional)") {
            Picker("Action", selection: $orgAction) {
                ForEach(OrgAction.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(SegmentedPickerStyle())

            if orgAction != .none {
                HStack {
                    TextField("Organization Name", text: $organizationName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)

                    Button(orgAction == .join ? "Search" : "Create") {
                        activeSheet = orgAction == .join ? .search : .create
                    }
                    .disabled(!orgNameValid)
                }
                if !orgNameValid && !organizationName.isEmpty {
                    errorText("Name 2–50 chars")
                }
                if orgAction == .join {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(availableRoles, id: \.self) { Text($0.capitalized) }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 20) {
            Button("Cancel") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Button("Save", action: registerUser)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(!isFormValid)
        }
        .padding(.vertical)
    }

    // MARK: – Helpers... (rest unchanged)
    
// MARK: – Helpers
private func debounceEmailCheck(_ newEmail: String) {
    emailStatus = .unknown
    emailDebounceWorkItem?.cancel()
    let workItem = DispatchWorkItem {
        checkEmailAvailability(email: newEmail.lowercased())
    }
    emailDebounceWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
}

@ViewBuilder
private var emailFeedbackView: some View {
    if !AccountValidator.isValidEmail(email.lowercased()),
       !email.isEmpty {
        errorText("Invalid email")
    } else {
        switch emailStatus {
        case .checking:
            HStack(spacing: 4) {
                ProgressView().scaleEffect(0.6)
                Text("Checking…").font(.caption2)
            }
        case .taken:
            errorText("Email already registered")
        case .available:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Available")
                    .foregroundColor(.green)
                    .font(.caption2)
            }
        case .error:
            Text("Could not verify")
                .foregroundColor(.orange)
                .font(.caption2)
        default:
            EmptyView()
        }
    }
}

private func ruleRow(_ text: String, _ passed: Bool) -> some View {
    Label(text,
          systemImage: passed ? "checkmark.circle" : "xmark.circle")
        .foregroundColor(passed ? .green : .secondary)
}

private func errorText(_ msg: String) -> some View {
    Text(msg)
        .foregroundColor(.red)
        .font(.caption2)
}

private func checkEmailAvailability(email: String) {
    guard AccountValidator.isValidEmail(email) else { return }
    emailStatus = .checking
    Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
        if error != nil {
            emailStatus = .error
        } else if let methods, !methods.isEmpty {
            emailStatus = .taken
        } else {
            emailStatus = .available
        }
    }
}

// MARK: – Registration
private func registerUser() {
    guard emailValid else { return }
    isLoading = true
    errorMessage = nil

    Auth.auth().createUser(withEmail: email.lowercased(),
                           password: password) { authResult, err in
        if let err = err {
            isLoading = false
            errorMessage = "Account creation failed: \(err.localizedDescription)"
            return
        }
        guard let uid = authResult?.user.uid else {
            isLoading = false
            errorMessage = "Unable to obtain user ID"
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
            organizationId: organizationId,           // nil if no org yet
            organizationName: orgAction == .none ? nil : organizationName,
            role: orgAction == .none ? nil : selectedRole,
            pendingApproval: pending,
            isOrgAdmin: (orgAction == .create),
            profilePictureURL: nil,
            createdAt: Date()
        )

        FirestoreManager.shared.createUser(user: newUser) { result in
            isLoading = false
            switch result {
            case .success():
                dismiss()
            case .failure(let saveError):
                errorMessage = "Failed to save user: \(saveError.localizedDescription)"
            }
        }
    }
}
}

// MARK: – Preview
#Preview {
CreateAccountView()
}
