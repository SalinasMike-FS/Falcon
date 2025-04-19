
//
//  OrgSearchOverlay.swift
//  Falcon
//
//  Overlay for joining an existing organization.
//

import SwiftUI

struct OrgSearchOverlay: View {
    @Binding var query: String
    @Binding var selectedOrgID: String?
    @Environment(\.dismiss) private var dismiss

    @State private var results: [(id: String, name: String)] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    ProgressView("Searching…")
                } else if results.isEmpty {
                    Text("No organizations found for \"\(query)\"")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(results, id: \.id) { org in
                        Button(org.name) {
                            selectedOrgID = org.id
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Join Organization")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear(perform: search)
        }
    }

    private func search() {
        isLoading = true
        FirestoreManager.shared.searchOrganizations(prefix: query) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let items): results = items
                case .failure(let error):
                    print("Org search error:", error)
                    results = []
                }
            }
        }
    }
}
