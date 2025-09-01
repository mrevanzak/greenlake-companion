//
//  TaskDetailView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct TaskDetailView: View {
  let task: LandscapingTask
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(task.title)
        .font(.title)
        .fontWeight(.bold)
      
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      Text(task.description)
        .font(.body)
        .padding(.bottom, 100)
      
      
      Spacer()
    }
    .padding()
  }
}
