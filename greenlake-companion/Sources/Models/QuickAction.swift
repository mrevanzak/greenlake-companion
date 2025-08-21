//
//  QuickAction.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import Foundation

// MARK: - Quick Action Model

struct QuickAction {
  let icon: String
  let title: String
  let action: () -> Void
}
