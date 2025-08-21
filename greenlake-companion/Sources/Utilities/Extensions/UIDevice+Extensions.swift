//
//  UIDevice+Extensions.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import UIKit

// MARK: - Device Detection Extension

extension UIDevice {
  static var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
  }
}
