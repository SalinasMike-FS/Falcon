//
//  ContentView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//  Updated 4/19/25 – supports onLogin callback.
//

import SwiftUI

struct ContentView: View {
    /// Called when sign‑in succeeds so the app can switch to DashboardView
    var onLogin: () -> Void

    @State private var showSignInView = false
    @State private var showCreateAccountView = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("falcon")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("Welcome to Falcon")
                .font(.largeTitle).bold()
                .padding(.top, 20)

            Text("Please sign in or create an account to continue.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 15) {
                Button("Sign In") {
                    showSignInView = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 40)

                Button("Create Account") {
                    showCreateAccountView = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .sheet(isPresented: $showSignInView) {
            SignInView(onLogin: {
                // dismiss sheet, then notify app to switch root
                showSignInView = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onLogin()
                }
            })
        }
        .sheet(isPresented: $showCreateAccountView) {
            CreateAccountView()
        }
    }
}

// MARK: – Preview
#Preview {
    ContentView(onLogin: {})
}
