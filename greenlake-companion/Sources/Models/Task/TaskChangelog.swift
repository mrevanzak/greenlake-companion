//
//  TaskChangelog.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import Foundation
import SwiftUI

struct TaskChangelog: Identifiable, Hashable {
  let id = UUID()
  
  let userId : String
  let taskId : String
  let date : Date
  let statusBefore : TaskStatus?
  let statusAfter : TaskStatus
  let description : String?
  
  var images: [UIImage]? {
    let numOfImages = Int.random(in: 1...3)
    
    if statusBefore == nil && statusAfter == .aktif || statusAfter == .diajukan {
      return generateImages(numOfImages: numOfImages)
    } else if statusBefore != nil && statusAfter == .diperiksa || statusAfter == .selesai {
      return generateImages(numOfImages: numOfImages)
    } else {
      return nil
    }
  }
  
  // Generate dummy data for images
  private func generateImages(numOfImages: Int) -> [UIImage] {
    var generatedImages: [UIImage] = []

    for _ in 1...numOfImages {
      let systemImageName = ["img1", "img2", "img3", "img4"].randomElement()
      let newImage = UIImage(named:systemImageName!)
      generatedImages.append(newImage!)
    }
    
    return generatedImages
  }
}
