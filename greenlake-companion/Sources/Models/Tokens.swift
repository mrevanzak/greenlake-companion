//
//  Tokens.swift
//  greenlake-companion
//
//  Created by Revanza Kurniawan on 21/08/25.
//

import Foundation

struct Tokens: Codable {
  let accessToken: String
  let refreshToken: String

  enum CodingKeys: String, CodingKey {
    case accessToken
    case refreshToken
  }
}
