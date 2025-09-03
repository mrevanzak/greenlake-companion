//
//  PDFBuilder.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import PDFKit
import UIKit

// A custom enum for image alignment for better clarity
enum ImageAlignment {
  case left, center, right
}

class PDFBuilder {
  /// The current vertical position on the page.
  private var currentY: CGFloat = 0
  
  /// The graphics context of the PDF, accessible during the build process.
  /// This is necessary for starting new pages.
  private var context: UIGraphicsPDFRendererContext?
  
  private let pageRect: CGRect
  private let renderer: UIGraphicsPDFRenderer
  
  // Constants for layout
  private let margin: CGFloat = 36.0
  private let spacing: CGFloat = 12.0
  
  init() {
    let pageWidth = 8.5 * 72.0
    let pageHeight = 11 * 72.0
    self.pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    
    let pdfMetaData = [
      kCGPDFContextCreator: "Component-Based PDF Builder",
      kCGPDFContextAuthor: "Your App",
    ]
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]
    self.renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
  }
  
  /// Creates the PDF data by executing a sequence of drawing commands.
  func createPDF(build: (PDFBuilder) -> Void) -> Data {
    let data = renderer.pdfData { (context) in
      // Store the context so other methods can access it
      self.context = context
      
      // Start the first page
      context.beginPage()
      self.currentY = margin
      
      // Execute the drawing commands
      build(self)
      
      // Clean up the context
      self.context = nil
    }
    return data
  }
  
  // MARK: - Drawing Functions
  
  /// Draws the report page header consisting of a logo, title, and metadata
  func drawHeader(title: String, sender: String, date: Date) {
    guard let logo = UIImage(named: "company_logo") else {
      drawTitle(text: title)
      drawHorizontalRule()
      return
    }
    
    let logoHeight: CGFloat = 64.0
    let aspectRatio = logo.size.width / logo.size.height
    let logoWidth = logoHeight * aspectRatio
    let logoRect = CGRect(x: margin, y: currentY, width: logoWidth, height: logoHeight)
    logo.draw(in: logoRect)
    
    let titleFont = UIFont.systemFont(ofSize: 30, weight: .semibold)
    let subheadlineFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    let centeredParagraphStyle = NSMutableParagraphStyle()
    centeredParagraphStyle.alignment = .center
    
    let attributedTitle = NSAttributedString(string: title, attributes: [.font: titleFont, .foregroundColor: UIColor.black, .paragraphStyle: centeredParagraphStyle])
    let attributedSubheadline = NSAttributedString(string: "CITY MANAGEMENT DEPARTMENT", attributes: [.font: subheadlineFont, .foregroundColor: UIColor.black, .paragraphStyle: centeredParagraphStyle])
    
    let titleHeight = attributedTitle.size().height
    let subheadlineHeight = attributedSubheadline.size().height
    let totalTextHeight = titleHeight + subheadlineHeight
    let textBlockY = currentY + (logoHeight - totalTextHeight) / 2.0
    
    let textX = logoRect.maxX + spacing
    let textWidth = pageRect.width - textX - margin
    
    let titleRect = CGRect(x: textX, y: textBlockY, width: textWidth, height: titleHeight)
    attributedTitle.draw(in: titleRect)
    
    let subheadlineRect = CGRect(x: textX, y: titleRect.maxY + 4, width: textWidth, height: subheadlineHeight)
    attributedSubheadline.draw(in: subheadlineRect)
    
    currentY = logoRect.maxY + (spacing / 2) // Move below logo with less spacing
    
    // Draw first line with manual control
    _drawHorizontalLineOnly(at: currentY)
    currentY += 6.0
    
    // Right-hand side styling
    let valueFont = UIFont.systemFont(ofSize: 12, weight: .bold)
    let valueColor = UIColor.black
    
    // Left-hand side styling
    let labelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    let labelColor = UIColor.gray
    
    let metadataPadding: CGFloat = 20.0
    
    // Left part: Combine a gray label with a bold value
    let sentByLabel = NSAttributedString(string: "Penanggung Jawab: ", attributes: [.font: labelFont, .foregroundColor: labelColor])
    let sentByValue = NSAttributedString(string: sender, attributes: [.font: valueFont, .foregroundColor: valueColor])
    let fullSentByText = NSMutableAttributedString(attributedString: sentByLabel)
    fullSentByText.append(sentByValue)
    
    let sentByTextSize = fullSentByText.size()
    let sentByRect = CGRect(x: margin + metadataPadding, y: currentY, width: sentByTextSize.width, height: sentByTextSize.height)
    fullSentByText.draw(in: sentByRect)
    
    // Right part: Combine a gray label with a bold value
    let dateLabel = NSAttributedString(string: "Periode: ", attributes: [.font: labelFont, .foregroundColor: labelColor])
    let dateValue = NSAttributedString(string: dateFormatter.string(from: date), attributes: [.font: valueFont, .foregroundColor: valueColor])
    let fullDateText = NSMutableAttributedString(attributedString: dateLabel)
    fullDateText.append(dateValue)
    
    let dateTextSize = fullDateText.size()
    let dateRect = CGRect(x: pageRect.width - margin - metadataPadding - dateTextSize.width, y: currentY, width: dateTextSize.width, height: dateTextSize.height)
    fullDateText.draw(in: dateRect)
    
    currentY += sentByTextSize.height + 6.0 // Move below metadata with small gap
    
    // Draw second line with manual control
    _drawHorizontalLineOnly(at: currentY)
    currentY += spacing // Add standard spacing below the full header
  }
  
  /// Draws a task's info in detail.
  func drawTaskReminder(task: LandscapingTask) {
      // --- 1. Draw Title ---
      let title = task.title
      let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
      // Using the generic drawText helper which already handles page breaks
      drawText(title, font: titleFont, alignment: .left, color: .black)
      
      // --- 2. Draw Image Gallery ---
      // This helper calculates height, handles page breaks, and draws the images
      _drawWrappingImageList(for: task)
      
      // --- 3. Draw Description ---
      // The existing drawParagraph function is perfect for this
      drawParagraph(text: task.description, alignment: .left, fontSize: 16)
      
      // --- 4. Draw Key-Value Details ---
      // This helper handles the formatted details section
    _drawKeyValueDetails(for: task, fontSize: 16.0)
  }
  
  /// Draws a table containing details of tasks where the vendor needs to pay a fine
  func drawFineTable(finedTasks: [LandscapingTask]) {
    // 1. Draw the main title for this section
    let title = "Daftar Keterlambatan dan Denda"
    let titleFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
    // Using a generic drawText call for more control over font
    drawText(title, font: titleFont, alignment: .left, color: .black)
    
    // 2. Define table layout constants
    let headerHeight: CGFloat = 28
    let rowHeight: CGFloat = 32
    
    // 3. Check if the header and at least one row will fit
    checkForPageBreak(addingHeight: headerHeight + rowHeight)
    
    // 4. Draw the initial table header
    _drawTableHeader(at: currentY, height: headerHeight)
    currentY += headerHeight
    
    // 5. Loop through tasks and draw each row
    for (index, task) in finedTasks.enumerated() {
      // Before drawing the next row, check if it fits
      checkForPageBreak(addingHeight: rowHeight)
      
      // If a page break occurred, the cursor is at the top. Redraw the header.
      if currentY == margin {
        _drawTableHeader(at: currentY, height: headerHeight)
        currentY += headerHeight
      }
      
      // Prepare row data
      let rowData: [String] = [
        "\(index + 1)",
        task.title,
        dateFormatter.string(from: task.dueDate), // Using dueDate as per request
        _calculateOverdueDuration(from: task.dueDate, to: task.dateClosed),
        "\(String(format: "%.2f", task.size)) \(task.unit)",
        "" // Blank Price column
      ]
      
      _drawTableRow(data: rowData, at: currentY, height: rowHeight)
      currentY += rowHeight
    }
    
    currentY += spacing * 2   // Double spacing after last row
    drawText("Total:  ____________________", font: UIFont.systemFont(ofSize: 14, weight: .semibold), alignment: .right, color: UIColor.black)
  }
  
  // Draws a list of tasks in a 2-column format
  func drawTasks(tasks: [LandscapingTask]) {
    let columnSpacing: CGFloat = 20.0
    let columnWidth = (pageRect.width - (2 * margin) - columnSpacing) / 2
    
    // Process tasks in pairs to create rows
    for i in stride(from: 0, to: tasks.count, by: 2) {
      // --- 1. Measure Pass ---
      let leftTask = tasks[i]
      let leftHeight = calculateTaskHeight(task: leftTask, width: columnWidth)
      
      var rightHeight: CGFloat = 0
      if i + 1 < tasks.count {
        let rightTask = tasks[i + 1]
        rightHeight = calculateTaskHeight(task: rightTask, width: columnWidth)
      }
      
      let rowHeight = max(leftHeight, rightHeight)
      checkForPageBreak(addingHeight: rowHeight)
      
      // --- 2. Draw Pass ---
      let leftFrame = CGRect(x: margin, y: currentY, width: columnWidth, height: rowHeight)
      drawSingleTask(task: leftTask, in: leftFrame)
      
      if i + 1 < tasks.count {
        let rightTask = tasks[i + 1]
        let rightFrameX = margin + columnWidth + columnSpacing
        let rightFrame = CGRect(x: rightFrameX, y: currentY, width: columnWidth, height: rowHeight)
        drawSingleTask(task: rightTask, in: rightFrame)
      }
      
      // --- 3. Update Cursor ---
      currentY += rowHeight + spacing
    }
  }
  
  /// Draws a title with a large, bold font.
  func drawTitle(text: String, alignment: NSTextAlignment = .center) {
    let titleFont = UIFont.systemFont(ofSize: 24.0, weight: .bold)
    drawText(text, font: titleFont, alignment: alignment, color: .black)
  }
  
  /// Draws a paragraph with a standard body font.
  func drawParagraph(text: String, alignment: NSTextAlignment = .justified, fontSize: CGFloat = 12.0) {
    let bodyFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
    
    // First, calculate the height of the text block
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    let attributes: [NSAttributedString.Key: Any] = [.font: bodyFont, .foregroundColor: UIColor.darkGray, .paragraphStyle: paragraphStyle]
    let attributedText = NSAttributedString(string: text, attributes: attributes)
    let availableWidth = pageRect.width - (2 * margin)
    let textHeight = attributedText.boundingRect(with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
    
    // ** Check for page break BEFORE drawing **
    checkForPageBreak(addingHeight: textHeight)
    
    // Now draw the text at the (potentially new) currentY
    let textRect = CGRect(x: margin, y: currentY, width: availableWidth, height: textHeight)
    attributedText.draw(in: textRect)
    currentY = textRect.maxY + 8.0
  }
  
  /// Draws a single, scaled image.
  func drawImage(image: UIImage, alignment: ImageAlignment = .center) {
    let maxWidth = pageRect.width - (2 * margin)
    let maxHeight = pageRect.height * 0.4
    
    let aspectRatio = min(maxWidth / image.size.width, maxHeight / image.size.height)
    let scaledHeight = image.size.height * aspectRatio
    
    // ** Check for page break BEFORE drawing **
    checkForPageBreak(addingHeight: scaledHeight)
    
    let scaledWidth = image.size.width * aspectRatio
    var imageX: CGFloat
    switch alignment {
    case .left: imageX = margin
    case .center: imageX = (pageRect.width - scaledWidth) / 2.0
    case .right: imageX = pageRect.width - scaledWidth - margin
    }
    
    let imageRect = CGRect(x: imageX, y: currentY, width: scaledWidth, height: scaledHeight)
    image.draw(in: imageRect)
    currentY = imageRect.maxY + spacing
  }
  
  /// Draws a simple horizontal line across the page.
  func drawHorizontalRule() {
    let context = UIGraphicsGetCurrentContext()!
    context.saveGState()
    
    context.setStrokeColor(UIColor.lightGray.cgColor)
    context.setLineWidth(1.0)
    
    let lineY = currentY + (spacing / 2.0)
    context.move(to: CGPoint(x: margin, y: lineY))
    context.addLine(to: CGPoint(x: pageRect.width - margin, y: lineY))
    context.strokePath()
    
    context.restoreGState()
    
    // Update Y position
    currentY += spacing * 2
  }
  
  // MARK: - Helper Functions
  
  private func checkForPageBreak(addingHeight height: CGFloat) {
    // Use the same margin for top and bottom
    let bottomMargin = self.margin
    
    // If the bottom of the new content would be below the bottom margin,
    // then create a new page.
    if currentY + height > pageRect.height - bottomMargin {
      context?.beginPage()
      currentY = margin
    }
  }
  
  /// Draws a horiozntal rule at a specific Y point (ignores default spacing)
  private func _drawHorizontalLineOnly(at yPosition: CGFloat) {
    guard let context = self.context?.cgContext else { return }
    context.saveGState()
    context.setStrokeColor(UIColor.lightGray.cgColor)
    context.setLineWidth(1.0)
    context.move(to: CGPoint(x: margin, y: yPosition))
    context.addLine(to: CGPoint(x: pageRect.width - margin, y: yPosition))
    context.strokePath()
    context.restoreGState()
  }
  
  /// Helper function that draws a single task's content within a given frame.
  private func drawSingleTask(task: LandscapingTask, in frame: CGRect) {
    let internalPadding: CGFloat = 10.0
    var contentY = frame.minY + internalPadding
    let contentX = frame.minX + internalPadding
    let contentWidth = frame.width - (2 * internalPadding)
    
    // Draw Images
    if let documentation = task.taskTimeline.last?.images, !documentation.isEmpty {
      let imageSize = CGSize(width: 100, height: 100)
      var imageX = contentX
      for image in documentation.prefix(2) {
        let imageRect = CGRect(origin: CGPoint(x: imageX, y: contentY), size: imageSize)
        image.draw(in: imageRect)
        imageX += imageSize.width + (internalPadding / 2)
      }
      contentY += imageSize.height + spacing
    }
    
    // Draw Title
    let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    let attributedTitle = NSAttributedString(string: task.title, attributes: [.font: titleFont])
    let titleHeight = attributedTitle.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    let titleRect = CGRect(x: contentX, y: contentY, width: contentWidth, height: titleHeight)
    attributedTitle.draw(in: titleRect)
    contentY += titleHeight + (spacing / 2)
    
    // Draw Description
    let descriptionFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    let attributedDescription = NSAttributedString(string: task.description, attributes: [.font: descriptionFont, .foregroundColor: UIColor.darkGray])
    let descriptionHeight = attributedDescription.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    let descriptionRect = CGRect(x: contentX, y: contentY, width: contentWidth, height: descriptionHeight)
    attributedDescription.draw(in: descriptionRect)
    contentY += descriptionHeight + spacing
    
    // Draw Key-Value Details
    let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    let details: [(key: String, value: String)] = [
      ("Tanaman", task.plantInstance),
      ("Lokasi", task.location),
      ("Ukuran", "\(String(format: "%.2f", task.size)) \(task.unit)"),
      ("Tenggat Waktu", dateFormatter.string(from: task.dueDate))]
    for detail in details {
      let keyText = NSAttributedString(string: detail.key, attributes: [.font: detailsFont, .foregroundColor: UIColor.gray])
      let valueText = NSAttributedString(string: detail.value, attributes: [.font: detailsFont, .foregroundColor: UIColor.black])
      let valueSize = valueText.size()
      let lineHeight = valueSize.height
      let keyRect = CGRect(x: contentX, y: contentY, width: contentWidth / 2, height: lineHeight)
      keyText.draw(in: keyRect)
      let valueRect = CGRect(x: frame.maxX - internalPadding - valueSize.width, y: contentY, width: valueSize.width, height: lineHeight)
      valueText.draw(in: valueRect)
      contentY += lineHeight + (spacing / 2)
    }
    
    // Draw Container
    let roundedPath = UIBezierPath(roundedRect: frame, cornerRadius: 8.0)
    roundedPath.lineWidth = 1.0
    UIColor.lightGray.setStroke()
    roundedPath.stroke()
  }
  
  /// Helper function that calculates the required height for a task without drawing it.
  private func calculateTaskHeight(task: LandscapingTask, width: CGFloat) -> CGFloat {
    var calculatedHeight: CGFloat = 0
    let internalPadding: CGFloat = 10.0
    let contentWidth = width - (2 * internalPadding)
    
    calculatedHeight += internalPadding // Top padding
    
    if let documentation = task.taskTimeline.last?.images, !documentation.isEmpty {
      calculatedHeight += 100 + spacing // Image height
    }
    
    let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    let attributedTitle = NSAttributedString(string: task.title, attributes: [.font: titleFont])
    let titleHeight = attributedTitle.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    calculatedHeight += titleHeight + (spacing / 2)
    
    let descriptionFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    let attributedDescription = NSAttributedString(string: task.description, attributes: [.font: descriptionFont, .foregroundColor: UIColor.darkGray])
    let descriptionHeight = attributedDescription.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    calculatedHeight += descriptionHeight + spacing
    
    let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    let details: [(key: String, value: String)] = [("Plant", task.plantInstance), ("Location", task.location), ("Size", "\(task.size) \(task.unit)"), ("Deadline", dateFormatter.string(from: task.dueDate))]
    let valueText = NSAttributedString(string: "Test", attributes: [.font: detailsFont, .foregroundColor: UIColor.black])
    let lineHeight = valueText.size().height
    let detailsHeight = (lineHeight + (spacing / 2)) * CGFloat(details.count)
    calculatedHeight += detailsHeight
    
    calculatedHeight += internalPadding // Bottom padding
    
    return calculatedHeight
  }
  
  /// A generic helper function to draw text.
  private func drawText(_ text: String, font: UIFont, alignment: NSTextAlignment, color: UIColor) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraphStyle
    ]
    
    let attributedText = NSAttributedString(string: text, attributes: attributes)
    
    let availableWidth = pageRect.width - (2 * margin)
    let textHeight = attributedText.boundingRect(
      with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
      options: .usesLineFragmentOrigin,
      context: nil
    ).height
    
    let textRect = CGRect(x: margin, y: currentY, width: availableWidth, height: textHeight)
    attributedText.draw(in: textRect)
    
    // Update Y position
    currentY = textRect.maxY + spacing
  }
  
  /// Draws the header row for the fines table at a specific Y position.
  private func _drawTableHeader(at y: CGFloat, height: CGFloat) {
    let columnWidths = calculateColumnWidths()
    var currentX: CGFloat = margin
    
    // Draw gray background for the header
    let backgroundRect = CGRect(x: margin, y: y, width: pageRect.width - (2 * margin), height: height)
    UIColor.lightGray.withAlphaComponent(0.3).setFill()
    UIRectFill(backgroundRect)
    
    let headerTitles = ["No.", "Pekerjaan", "Tanggal", "Durasi", "Ukuran", "Denda"]
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
      .foregroundColor: UIColor.black
    ]
    
    for (index, title) in headerTitles.enumerated() {
      let cellRect = CGRect(x: currentX, y: y, width: columnWidths[index], height: height)
      drawTextInCell(NSAttributedString(string: title, attributes: attributes), in: cellRect)
      currentX += columnWidths[index]
    }
  }
  
  /// Draws a single content row for the fines table.
  private func _drawTableRow(data: [String], at y: CGFloat, height: CGFloat) {
    let columnWidths = calculateColumnWidths()
    var currentX: CGFloat = margin
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 9, weight: .regular),
      .foregroundColor: UIColor.darkGray
    ]
    
    for (index, item) in data.enumerated() {
      let cellRect = CGRect(x: currentX, y: y, width: columnWidths[index], height: height)
      drawTextInCell(NSAttributedString(string: item, attributes: attributes), in: cellRect)
      currentX += columnWidths[index]
    }
    
    // Draw a bottom border for the row
    _drawHorizontalLineOnly(at: y + height)
  }
  
  /// A centralized place to define column widths.
  private func calculateColumnWidths() -> [CGFloat] {
    let totalWidth = pageRect.width - (2 * margin)
    return [
      totalWidth * 0.05, // No.
      totalWidth * 0.35, // Title
      totalWidth * 0.15, // Date
      totalWidth * 0.15, // Duration
      totalWidth * 0.15, // Size
      totalWidth * 0.15  // Price
    ]
  }
  
  /// Draws text vertically centered within a cell's rectangle.
  private func drawTextInCell(_ text: NSAttributedString, in rect: CGRect) {
    let padding: CGFloat = 5.0
    let textHeight = text.size().height
    let textY = rect.origin.y + (rect.height - textHeight) / 2
    let textRect = CGRect(x: rect.origin.x + padding,
                          y: textY,
                          width: rect.width - (2 * padding),
                          height: textHeight)
    text.draw(in: textRect)
  }
  
  /// Calculates the difference in days between two dates.
  private func _calculateOverdueDuration(from dueDate: Date, to completionDate: Date?) -> String {
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

  /// Draws a list of images that wrap to a new line if they exceed the page width.
  private func _drawWrappingImageList(for task: LandscapingTask) {
      guard let documentation = task.taskTimeline.last?.images, !documentation.isEmpty else {
          return
      }
      
      let maxImageHeight: CGFloat = 160.0
      let imageSpacing: CGFloat = 10.0
      
      // --- 1. Measurement Pass ---
      // First, calculate the total height the gallery will occupy without drawing anything.
      var totalGalleryHeight: CGFloat = 0
      var currentX: CGFloat = margin
      var rowMaxHeight: CGFloat = 0

      for image in documentation {
          let aspectRatio = image.size.width / image.size.height
          let scaledHeight = min(image.size.height, maxImageHeight)
          let scaledWidth = scaledHeight * aspectRatio
          
          // Check for wrap
          if currentX + scaledWidth > pageRect.width - margin {
              totalGalleryHeight += rowMaxHeight + imageSpacing
              currentX = margin
              rowMaxHeight = 0
          }
          
          currentX += scaledWidth + imageSpacing
          rowMaxHeight = max(rowMaxHeight, scaledHeight)
      }
      totalGalleryHeight += rowMaxHeight // Add height of the last row
      
      // --- 2. Page Break Check ---
      checkForPageBreak(addingHeight: totalGalleryHeight)
      
      // --- 3. Drawing Pass ---
      // Now, perform the same layout logic, but actually draw the images.
      currentX = margin
      let startY = currentY
      
      for image in documentation {
          let aspectRatio = image.size.width / image.size.height
          let scaledHeight = min(image.size.height, maxImageHeight)
          let scaledWidth = scaledHeight * aspectRatio
          
          if currentX + scaledWidth > pageRect.width - margin {
              currentY += rowMaxHeight + imageSpacing
              currentX = margin
              rowMaxHeight = 0
          }
          
          let imageRect = CGRect(x: currentX, y: currentY, width: scaledWidth, height: scaledHeight)
          image.draw(in: imageRect)
          
          currentX += scaledWidth + imageSpacing
          rowMaxHeight = max(rowMaxHeight, scaledHeight)
      }
      
      // Update main Y cursor to be below the entire gallery
      currentY = startY + totalGalleryHeight + spacing
  }

  /// Draws the key-value details section for a task.
  private func _drawKeyValueDetails(for task: LandscapingTask, fontSize: CGFloat = 10.0) {
      let detailsFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
      let details: [(key: String, value: String)] = [
          ("Tanaman", task.plantInstance),
          ("Lokasi", task.location),
          ("Ukuran", "\(String(format: "%.2f", task.size)) \(task.unit)"),
          ("Tenggat Waktu", dateFormatter.string(from: task.dueDate))
      ]
      
      // --- 1. Measurement Pass ---
      let valueTextSample = NSAttributedString(string: "Test", attributes: [.font: detailsFont])
      let lineHeight = valueTextSample.size().height
      let totalHeight = (lineHeight + (spacing / 2)) * CGFloat(details.count)
      
      // --- 2. Page Break Check ---
      checkForPageBreak(addingHeight: totalHeight)
      
      // --- 3. Drawing Pass ---
      let contentWidth = pageRect.width - (2 * margin)
      for detail in details {
          let keyText = NSAttributedString(string: detail.key, attributes: [.font: detailsFont, .foregroundColor: UIColor.gray])
          let valueText = NSAttributedString(string: detail.value, attributes: [.font: detailsFont, .foregroundColor: UIColor.black])
          
          let valueSize = valueText.size()
          let lineHeight = valueSize.height
          
          let keyRect = CGRect(x: margin, y: currentY, width: contentWidth / 2, height: lineHeight)
          keyText.draw(in: keyRect)
          
          let valueRect = CGRect(x: pageRect.width - margin - valueSize.width, y: currentY, width: valueSize.width, height: lineHeight)
          valueText.draw(in: valueRect)
          
          currentY += lineHeight + (spacing / 2)
      }
      // Add final spacing after the block
      currentY += spacing
  }
}
