//
//  CatalogView.swift
//  Falcon
//
//  Created by Michael Salinas on 4/14/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search parts, tools, or supplies...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct CatalogView: View {
    @State private var selectedCategory: String? = nil
    @State private var userName: String = "Welcome, Mike"
    @State private var searchText: String = ""
    @State private var animateHeader: Bool = false

    let categories = ["Tools", "Parts", "Supplies", "Misc"]
    let subcategories = [
        "Tools": ["Hammers", "Drills", "Wrenches"],
        "Parts": ["Bearings", "Bolts", "Gears"],
        "Supplies": ["Tape", "Wire", "Glue"],
        "Misc": ["Labels", "Batteries", "Cases"]
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Catalog")
                    .font(.largeTitle)
                    .bold()
                    .offset(x: animateHeader ? 0 : -100)
                    .opacity(animateHeader ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: animateHeader)
                Spacer()
                Text(userName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .offset(x: animateHeader ? 0 : 100)
                    .opacity(animateHeader ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateHeader)
            }
            .padding([.horizontal, .top])
            
            SearchBar(text: $searchText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            if let selected = selectedCategory, let subs = subcategories[selected] {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subcategories")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(subs, id: \.self) { sub in
                        HStack {
                            Image(systemName: "cube.box") // Placeholder image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .padding(.trailing, 8)
                            Text(sub)
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2))
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            animateHeader = true
        }
    }
}


#Preview {
    CatalogView()
}
