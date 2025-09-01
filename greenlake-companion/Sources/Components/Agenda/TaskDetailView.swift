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
    VStack(alignment: .leading, spacing: 30) {
      // Header
      VStack(alignment: .leading) {
        HStack(alignment: .bottom) {
          Text(task.title)
            .font(.title)
            .fontWeight(.bold)
          
          Text(task.urgencyLabel.displayName)
            .font(.subheadline)
            .foregroundColor(task.urgencyLabel.displayColor)
            .bold()
          
          Spacer()
          
          Menu {
            Button("Option A", action: { print("Option A selected") })
            Button("Option B", action: { print("Option B selected") })
            Button("Option C", action: { print("Option C selected") })
            
          } label: {
            Label("Pilih Konfirmasi", systemImage: "checkmark")
              .padding(10)
              .foregroundColor(.white)
              .background(.blue)
              .cornerRadius(10)
          }
          
//          Button {
//            print("Inline export button")
//          } label: {
//            Image(systemName: "square.and.arrow.up")
//              .font(.title3)
//              .padding(10)
//              .foregroundColor(.white) // Make the checkmark white
//              .background(Color.secondary) // Set the background color for the circle
//              .clipShape(Circle()) // 2. Clip the background into a circle shape.
//          }
        }
        
        Text(task.location)
          .font(.subheadline)
          .bold()
        
        Text(task.plantInstance)
          .font(.subheadline)
          .italic()
        
        HStack {
          Text("Status Pekerjaan")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .italic()
            .bold()
          
          Text(task.status.displayName)
            .font(.subheadline)
            .foregroundColor(.primary)
            .bold()
          
          Spacer()
        }
      }
      
      VStack(alignment: .leading) {
        Text("Dokumentasi")
          .font(.title3)
          .bold()
        
        HStack(spacing: 20) {
          VStack(alignment: .leading, spacing: 10) {
            Image("img1")
              .resizable()
              .scaledToFit()
      
            Text("Sebelum,\n\(dateFormatter.string(from: task.dateCreated))")
            
            VStack(alignment: .leading) {
              Text("Catatan")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .bold()
              
              Text(task.description)
            }
          }
          
          Spacer()
          
          VStack(alignment: .leading, spacing: 10) {
            Image("img3")
              .resizable()
              .scaledToFit()
            
            Text("Sesudah,\n\(dateFormatter.string(from: Date()))")
            
            VStack(alignment: .leading) {
              Text("Catatan")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .bold()
              
              Text(task.description)
            }
          }
        }
      }
      
      VStack(alignment: .leading) {
        Text("Riwayat Pengerjaan")
          .font(.title3)
          .bold()
        
        LazyVStack(spacing: 10) {
          ForEach(1...4, id: \.self) { index in
            HStack(spacing: 20) {
              Image("img\(index)")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
              
              VStack(alignment: .leading) {
                Text("Riwayat Pekerjaan 1")
                  .font(.subheadline)
                  .bold()
                
                Text("Deskripsi pekerjaan blablablablablabla blablablablablabla blablablablablabla blablablablablabla")
                  .font(.footnote)
              }
              
              Spacer()
              
              Text("2\(index)-06-2025")
                .foregroundColor(.secondary)
                .font(.footnote)
            }
          }
        }
      }
    }
    .padding()
  }
}
