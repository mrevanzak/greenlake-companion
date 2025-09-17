//
//  PDFBuilder + HelperMethods.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 11/09/25.
//

import PDFKit

extension PDFBuilder {
  func checkForPageBreak(addingHeight height: CGFloat) {
    // Use the same margin for top and bottom
    let bottomMargin = self.margin
    
    // If the bottom of the new content would be below the bottom margin,
    // then create a new page.
    if currentY + height > pageRect.height - bottomMargin {
      context?.beginPage()
      currentY = margin
    }
  }
  
  /// Helper function that calculates the required height for a task without drawing it.
  func calculateTaskHeight(task: LandscapingTask, images: [UIImage], width: CGFloat) -> CGFloat {
    var calculatedHeight: CGFloat = 0
    let internalPadding: CGFloat = 10.0
    let contentWidth = width - (2 * internalPadding)
    
    calculatedHeight += internalPadding
    
    // MODIFIED: Use the passed-in 'images' array directly
    if !images.isEmpty {
      calculatedHeight += 100 + spacing
    }
    
    // ... (Rest of this function is unchanged)
    let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    let attributedTitle = NSAttributedString(string: task.title, attributes: [.font: titleFont])
    let titleHeight = attributedTitle.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    calculatedHeight += titleHeight + (spacing / 2)
    
    let descriptionFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    let attributedDescription = NSAttributedString(string: task.description, attributes: [.font: descriptionFont, .foregroundColor: UIColor.darkGray])
    let descriptionHeight = attributedDescription.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    calculatedHeight += descriptionHeight + spacing
    
    let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    let details: [(key: String, value: String)] = [
      ("Tanaman", task.plant_name),
      ("Lokasi", task.location),
      ("Ukuran", "\(String(format: "%.2f", task.size)) \(task.unit)"),
      ("Tenggat Waktu", dateFormatter.string(from: task.dueDate))]
    let valueText = NSAttributedString(string: "Test", attributes: [.font: detailsFont, .foregroundColor: UIColor.black])
    let lineHeight = valueText.size().height
    let detailsHeight = (lineHeight + (spacing / 2)) * CGFloat(details.count)
    calculatedHeight += detailsHeight
    
    calculatedHeight += internalPadding
    
    return calculatedHeight
  }
  
  /// A centralized place to define column widths.
  func calculateColumnWidths() -> [CGFloat] {
    let totalWidth = pageRect.width - (2 * margin)
    return [
      totalWidth * 0.05,  // No.
      totalWidth * 0.35,  // Title
      totalWidth * 0.15,  // Date
      totalWidth * 0.15,  // Duration
      totalWidth * 0.15,  // Size
      totalWidth * 0.15,  // Price
    ]
  }
  
  /// Calculates the difference in days between two dates.
  func _calculateOverdueDuration(from dueDate: Date, to completionDate: Date?) -> String {
    guard let completionDate = completionDate else {
      return "In Progress"
    }
    
    // Ensure we only calculate if it's actually overdue
    guard completionDate > dueDate else {
      return "On Time"
    }
    
    let components = Calendar.current.dateComponents([.day], from: dueDate, to: completionDate)
    if let days = components.day, days > 0 {
      return "\(days) hari"
    }
    return "Same Day"
  }
}
