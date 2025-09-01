//
//  FilterPopover.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct FilterPopover: View {
  @ObservedObject var viewModel: FilterViewModel
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Filter")
          .font(.title3)
          .fontWeight(.bold)
          .padding(.bottom, 10)
        
        Spacer()
        
        Button {
          viewModel.resetFilters()
        } label: {
          Text("Reset")
            .foregroundColor(.red)
        }
      }
      
      Text("Tipe Tugas")
        .fontWeight(.bold)
      HStack {
        ForEach(TaskType.allCases) { taskType in
          FilterToggleButton(parameter: taskType, selection: $viewModel.taskType)
        }
      }
      .padding(.bottom, 10)
      
      Text("Urgensi")
        .fontWeight(.bold)
      HStack {
        ForEach(UrgencyLabel.allCases) { urgencyLabel in
          FilterToggleButton(parameter: urgencyLabel, selection: $viewModel.urgency)
        }
      }
      .padding(.bottom, 10)
      
      Text("Tipe Tanaman")
        .fontWeight(.bold)
      HStack {
        ForEach(PlantType.allCases) { plantType in
          FilterToggleButton(parameter: plantType, selection: $viewModel.plantType)
        }
      }
      .padding(.bottom, 10)
      
      Text("Status")
        .fontWeight(.bold)
      HStack {
        ForEach(TaskStatus.allCases) { status in
          FilterToggleButton(parameter: status, selection: $viewModel.status)
        }
      }
      .padding(.bottom, 10)
      
      Text("Waktu")
        .fontWeight(.bold)
      HStack(spacing: 24) {
        DatePicker(
          "Mulai",
          selection: $viewModel.startDate,
          displayedComponents: .date
        )
        
        DatePicker(
          "Hingga",
          selection: $viewModel.endDate,
          displayedComponents: .date
        )
      }
      
      Divider()
      
      Text("Urutkan")
        .font(.title3)
        .fontWeight(.bold)
        .padding(.bottom, 10)
      
      Text("Status")
        .fontWeight(.bold)
      HStack(spacing: 10) {
        ForEach(SortKey.allCases) { sortKey in
          SortingToggleButton(mySortKey: sortKey, sortKeyController: $viewModel.sortKey, sortOrderController: $viewModel.sortOrder)
        }
      }
      .padding(.bottom, 10)
    }
    .padding()
    .background(.ultraThinMaterial)
  }
}

#Preview {
  FilterPopover(viewModel: FilterViewModel())
}
