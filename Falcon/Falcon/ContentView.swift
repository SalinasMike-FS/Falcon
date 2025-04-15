//
//  ContentView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showCreateAccountView = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("falcon") // Make sure to add falcon.png to your Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("Welcome to Falcon")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            Text("Please sign in or create an account to continue.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 15) {
                Button(action: {
                    // Navigate to sign in screen
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }

                Button(action: {
                    showCreateAccountView = true
                }) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showCreateAccountView) {
            CreateAccountView()
        }
    }
}

#Preview {
    ContentView()
}
