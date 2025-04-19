
//
//  CreateOrganizationView.swift
//  Falcon
//
//  Elegant, animated view for creating an organization with plan selection and trial limitations.
//
//  Created by Michael Salinas on 4/18/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore

struct CreateOrganizationView: View {
    let name: String
    var onCreated: (_ orgId: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanTier?
    @State private var isLoading = false
    @State private var errorMessage: String?

    enum PlanTier: String, CaseIterable, Identifiable {
        var id: String { rawValue }

        case starter = "Starter"
        case growth = "Growth"
        case enterprise = "Enterprise"

        var description: String {
            switch self {
            case .starter: return "For small teams just getting started. Limited to 3 techs and 3 vehicles."
            case .growth: return "Best for growing teams. Includes warehouse sync and dispatch."
            case .enterprise: return "Full access with support, mapping, analytics, and advanced dispatch."
            }
        }

        var trialInfo: String {
            return "Includes 30-day free trial. No card required."
        }

        var limits: [String: Any] {
            switch self {
            case .starter:
                return ["maxTechs": 3, "maxVehicles": 3]
            case .growth:
                return ["maxTechs": 10, "maxVehicles": 10]
            case .enterprise:
                return ["maxTechs": 100, "maxVehicles": 100]
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Create Your Organization")
                            .font(.title)
                            .bold()
                        Text("Manage users, inventory, and field operations seamlessly.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Organization Name")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(name)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    VStack(spacing: 12) {
                        ForEach(PlanTier.allCases) { plan in
                            Button(action: {
                                withAnimation {
                                    selectedPlan = plan
                                }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(plan.rawValue)
                                            .font(.headline)
                                        if plan == selectedPlan {
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Text(plan.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(plan.trialInfo)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            }
                        }
                    }

                    if let plan = selectedPlan {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You selected:")
                                .font(.caption)
                            Text(plan.rawValue)
                                .font(.headline)
                            Text("Trial: 30 days free. Upgrade anytime to lift limits.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }

                    Button(action: createOrganization) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Confirm & Create Organization")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(selectedPlan == nil || isLoading)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Create Organization")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: .constant(errorMessage != nil)) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func createOrganization() {
        guard let plan = selectedPlan else { return }

        isLoading = true
        errorMessage = nil

        let orgId = UUID().uuidString
        let uid = Auth.auth().currentUser?.uid ?? "unknown"
        let now = Timestamp(date: Date())

        let orgRef = Firestore.firestore().collection("organizations").document(orgId)
        let warehouseRef = Firestore.firestore().collection("warehouses").document(orgId)

        let orgData: [String: Any] = [
            "name": name,
            "nameLC": name.lowercased(),
            "creatorId": uid,
            "createdAt": now,
            "planTier": plan.rawValue,
            "approved": false,
            "status": "pending",
            "trialStartedAt": now,
            "limits": plan.limits,
            "memberIds": [uid],
            "roles": ["admin", "tech", "manager", "dispatcher", "customer"]
        ]

        let warehouseData: [String: Any] = [
            "warehouseName": "Main Warehouse",
            "createdAt": now,
            "syncedToUsers": [],
            "items": [],
            "notes": "System-generated master warehouse"
        ]

        let batch = Firestore.firestore().batch()
        batch.setData(orgData, forDocument: orgRef)
        batch.setData(warehouseData, forDocument: warehouseRef)

        batch.commit { error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to create organization: \(error.localizedDescription)"
            } else {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                onCreated(orgId)
                dismiss()
            }
        }
    }
}


#Preview {
    CreateOrganizationView(name: "Demo Organization") { orgId in
        print("Created organization with ID: \(orgId)")
    }
}
