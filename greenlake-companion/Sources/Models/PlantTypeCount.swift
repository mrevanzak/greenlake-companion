//
//  PlantCount.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 12/09/25.
//


import Foundation

// MARK: - TimelineWrapper

struct PlantTypeCountData: Codable {
    let counts: [PlantTypeCount]
    let total: String
}

// MARK: - PlantTypeCount

struct PlantTypeCount: Codable {
    let type: String
    let count: String
}
