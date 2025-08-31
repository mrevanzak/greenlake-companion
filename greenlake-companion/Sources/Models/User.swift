//
//  User.swift
//  greenlake-companion
//
//  Created by Revanza Kurniawan on 21/08/25.
//

import Foundation

struct User: Codable, Identifiable {
  let id: Int
  let email: String
  let name: String
  let site: String
  let role: String

  enum CodingKeys: String, CodingKey {
    case id
    case email
    case name
    case site
    case role
  }
}
