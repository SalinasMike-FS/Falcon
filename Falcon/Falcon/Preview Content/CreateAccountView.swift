import SwiftUI
import Firebase

struct CreateAccountView: View {
    @State private var firstName = ""
    @State private var middleName = ""
    @State private var lastName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Name")) {
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                        TextField("Middle Name (optional)", text: $middleName)
                            .textContentType(.middleName)
                        TextField("Last Name", text: $lastName)
                            .textContentType(.familyName)
                    }

                    Section(header: Text("Location")) {
                        TextField("City", text: $city)
                            .textContentType(.addressCity)
                        TextField("State", text: $state)
                            .textContentType(.addressState)
                    }

                    Section(header: Text("Credentials")) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                        SecureField("Password", text: $password)
                            .textContentType(.newPassword)
                    }
                }

                VStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    Button(action: {
//                        let newUser = User(
//                            id: ObjectIdentifier(User.self),
//                            firstName: firstName,
//                            middleName: middleName.isEmpty ? nil : middleName,
//                            lastName: lastName,
//                            city: city,
//                            state: state,
//                            email: email,
//                            password: password
//                        )
//
//                        let userData: [String: Any] = [
//                            "firstName": firstName,
//                            "middleName": middleName.isEmpty ? NSNull() : middleName,
//                            "lastName": lastName,
//                            "city": city,
//                            "state": state,
//                            "email": email,
//                            "password": password
//                        ]
//
//                        Firestore.firestore().collection("users").addDocument(data: userData) { error in
//                            if let error = error {
//                                print("Error saving user: \(error.localizedDescription)")
//                            } else {
//                                print("User saved successfully")
//                                dismiss()
//                            }
//                        }
                    }) {
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
}

#Preview {
    CreateAccountView()
}
