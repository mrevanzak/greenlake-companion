//
//  TaskPreview.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import Foundation
import SwiftUI

struct TaskPreview: View {
  let task: LandscapingTask
  private let clipLength = 75
  
  var body: some View {
    HStack {
      // Read Indicator: Pending implementation (butuh ga ya?)
      //            Circle()
      //                .foregroundStyle(.blue)
      //                .frame(width: 8, height: 8)
      
      // Task icon
      Image(systemName: task.imageName)
        .font(.title)
        .frame(width: 60, height: 60)
        .foregroundColor(task.status.displayColor)
        .background(task.status.displayColor.opacity(0.35).brightness(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 8))
      
      Spacer()
      
      // Title and description
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          Text(task.title)
            .font(.headline)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
          
          Spacer()
          
          Text(dateFormatter.string(from: task.dateCreated))
            .font(.footnote)
            .opacity(0.8)
        }
        
        // Clip the description to 50 characters
        Text(String(task.description.prefix(clipLength)) + (task.description.count > clipLength ? "..." : ""))
          .font(.subheadline)
          .opacity(0.8)
          .lineLimit(2)
      }
      .padding(.leading, 10)
    }
  }
}
