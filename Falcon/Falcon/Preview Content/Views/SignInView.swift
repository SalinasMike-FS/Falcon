//
//  SignInView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//  Updated 4/19/25 – now accepts onLogin callback.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    // MARK: – Callback
    /// Called when sign‑in succeeds so FalconApp can switch to DashboardView
    var onLogin: () -> Void

    // MARK: – State
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    // MARK: – Validation
    private var emailOK: Bool { email.contains("@") && !email.isEmpty }
    private var passwordOK: Bool { !password.isEmpty }
    private var formValid: Bool { emailOK && passwordOK }

    // MARK: – Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Sign In")
                    .font(.largeTitle).bold()

                Group {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .submitLabel(.next)

                    SecureField("Password", text: $password)
                        .submitLabel(.go)
                        .onSubmit { login() }
                }
                .padding()
                .frame(height: 56)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    Button("Reset Password") { resetPassword() }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .disabled(!emailOK)

                    Button("Login") { login() }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(formValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(!formValid || isLoading)
                }

                Button("Cancel") { dismiss() }
                    .foregroundColor(.red)
                    .padding(.top, 24)

                Spacer()
            }
            .padding()
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        ProgressView().scaleEffect(1.3)
                    }
                }
            }
        }
    }

    // MARK: – Actions
    private func resetPassword() {
        guard emailOK else { return }
        isLoading = true; errorMessage = nil

        Auth.auth().sendPasswordReset(withEmail: email) { err in
            isLoading = false
            if let err {
                errorMessage = err.localizedDescription
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } else {
                errorMessage = "Password‑reset email sent."
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private func login() {
        guard formValid else { return }
        isLoading = true; errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { _, err in
            isLoading = false
            if let err {
                errorMessage = err.localizedDescription
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()   // close the sheet
                onLogin()   // notify FalconApp to switch root
            }
        }
    }
}

// MARK: – Preview
#Preview {
    SignInView(onLogin: {})
}
