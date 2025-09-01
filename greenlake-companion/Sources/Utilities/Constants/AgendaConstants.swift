//
//  AgendaConstants.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI
import Foundation

let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "dd-MM-yyyy"
  return formatter
}()

enum SortKey: String, CaseIterable, Identifiable {
  case dateCreated = "Date Created"
  case dateModified = "Date Modified"
  case dateClosed = "Date Closed"
  
  var id: String { self.rawValue }
}

enum SortingState {
  case notSelected
  case ascending
  case descending
}
