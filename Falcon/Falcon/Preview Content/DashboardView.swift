//
//  DashboardView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import SwiftUI

struct DashboardView: View {
    var userName: String = "Michael"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Top Bar
            HStack {
                Text("Falcon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .animation(.default)

                Spacer()

                Text("Welcome, \(userName)")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Inventory Status Cards
            HStack(spacing: 16) {
                InventoryCardView(title: "Truck", count: 28, low: 3, icon: "car.fill")
                InventoryCardView(title: "Warehouse", count: 123, low: 8, icon: "building.2.fill")
                InventoryCardView(title: "Catalog", count: 276, low: 0, icon: "folder.fill")
            }
            .padding(.horizontal)

            // Graph Placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("Inventory Usage Graph")
                        .foregroundColor(.gray)
                )
                .padding(.horizontal)

            // Alerts and Quick Actions
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("🔻 Low Inventory Alerts")
                    Text("🧯 Out-of-stock Warnings")
                    Text("🕓 Last updated 1 hour ago")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                VStack(spacing: 12) {
                    ActionButton(title: "Add Item", icon: "plus.circle")
                    ActionButton(title: "Restock Truck", icon: "shippingbox")
                    ActionButton(title: "Audit Warehouse", icon: "doc.text.magnifyingglass")
                    ActionButton(title: "Sync", icon: "arrow.triangle.2.circlepath")
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }
}

struct InventoryCardView: View {
    let title: String
    let count: Int
    let low: Int
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.headline)
            }
            Text("\(count) items")
                .font(.title)
                .bold()
            Text("\(low) low stock")
                .foregroundColor(low > 0 ? .orange : .green)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    DashboardView()
}
