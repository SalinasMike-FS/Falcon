//
//  LocationManager.swift
//  Falcon
//
//  Created by Michael Salinas on 4/18/25.
//

import Foundation
import Combine

/// Loads the StatesAndCities.json bundled with the app and
/// exposes a searchable list of states (keys).
final class LocationManager: ObservableObject {
    
    /// All state names, sorted A‑Z
    @Published private(set) var states: [String] = []
    
    /// Raw map: State → [City]
    private var stateCityMap: [String: [String]] = [:]
    
    /// The currently‑selected state (used by the form)
    @Published var selectedState: String = ""
    
    init() {
        loadJSON()
    }
    
    // MARK: ‑‑ Loading
    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "StatesAndCities",
                                        withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String]].self,
                                                      from: data) else {
            print("⚠️  Failed to load StatesAndCities.json")
            return
        }
        stateCityMap = decoded
        states = decoded.keys.sorted()
    }
    
    // MARK: ‑‑ Helpers
    
    /// Returns an alphabetised list of cities for the current state.
    /// If the JSON has empty arrays, you’ll get an empty list (we’re
    /// letting users type cities anyway).
    func citiesForSelectedState() -> [String] {
        stateCityMap[selectedState]?.sorted() ?? []
    }
    
    /// Optional future use: check whether a typed city already exists
    func doesCityExist(_ city: String) -> Bool {
        stateCityMap[selectedState]?.contains(city) ?? false
    }
}
