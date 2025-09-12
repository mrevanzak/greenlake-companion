//
//  PDFBuilder + DrawMethods.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 11/09/25.
//

import PDFKit

extension PDFBuilder {
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
    
    let attributedTitle = NSAttributedString(
      string: title,
      attributes: [
        .font: titleFont, .foregroundColor: UIColor.black, .paragraphStyle: centeredParagraphStyle,
      ])
    let attributedSubheadline = NSAttributedString(
      string: "CITY MANAGEMENT DEPARTMENT",
      attributes: [
        .font: subheadlineFont, .foregroundColor: UIColor.black,
        .paragraphStyle: centeredParagraphStyle,
      ])
    
    let titleHeight = attributedTitle.size().height
    let subheadlineHeight = attributedSubheadline.size().height
    let totalTextHeight = titleHeight + subheadlineHeight
    let textBlockY = currentY + (logoHeight - totalTextHeight) / 2.0
    
    let textX = logoRect.maxX + spacing
    let textWidth = pageRect.width - textX - margin
    
    let titleRect = CGRect(x: textX, y: textBlockY, width: textWidth, height: titleHeight)
    attributedTitle.draw(in: titleRect)
    
    let subheadlineRect = CGRect(
      x: textX, y: titleRect.maxY + 4, width: textWidth, height: subheadlineHeight)
    attributedSubheadline.draw(in: subheadlineRect)
    
    currentY = logoRect.maxY + (spacing / 2)  // Move below logo with less spacing
    
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
    let sentByLabel = NSAttributedString(
      string: "Penanggung Jawab: ", attributes: [.font: labelFont, .foregroundColor: labelColor])
    let sentByValue = NSAttributedString(
      string: sender, attributes: [.font: valueFont, .foregroundColor: valueColor])
    let fullSentByText = NSMutableAttributedString(attributedString: sentByLabel)
    fullSentByText.append(sentByValue)
    
    let sentByTextSize = fullSentByText.size()
    let sentByRect = CGRect(
      x: margin + metadataPadding, y: currentY, width: sentByTextSize.width,
      height: sentByTextSize.height)
    fullSentByText.draw(in: sentByRect)
    
    // Right part: Combine a gray label with a bold value
    let dateLabel = NSAttributedString(
      string: "Periode: ", attributes: [.font: labelFont, .foregroundColor: labelColor])
    let dateValue = NSAttributedString(
      string: dateFormatter.string(from: date),
      attributes: [.font: valueFont, .foregroundColor: valueColor])
    let fullDateText = NSMutableAttributedString(attributedString: dateLabel)
    fullDateText.append(dateValue)
    
    let dateTextSize = fullDateText.size()
    let dateRect = CGRect(
      x: pageRect.width - margin - metadataPadding - dateTextSize.width, y: currentY,
      width: dateTextSize.width, height: dateTextSize.height)
    fullDateText.draw(in: dateRect)
    
    currentY += sentByTextSize.height + 6.0  // Move below metadata with small gap
    
    // Draw second line with manual control
    _drawHorizontalLineOnly(at: currentY)
    currentY += spacing  // Add standard spacing below the full header
  }
  
  /// Draws a task's info in detail.
  func drawTaskReminder(task: LandscapingTask, images imagesDictionary: [UUID: [UIImage]], withSignTemplate: Bool = false) {
    let title = task.title
    let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
    let contentFontSize = 16.0
    
    drawText(title, font: titleFont, alignment: .left, color: .black)
    _drawWrappingImageList(images: imagesDictionary[task.id] ?? [], maxImageHeight: 240)

    drawParagraph(text: task.description, alignment: .left, fontSize: contentFontSize)
    _drawKeyValueDetails(for: task, fontSize: contentFontSize)
    
    if withSignTemplate {
      _drawSigningTemplate()
    }
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
        dateFormatter.string(from: task.dueDate),  // Using dueDate as per request
        _calculateOverdueDuration(from: task.dueDate, to: task.dateClosed),
        "\(String(format: "%.2f", task.size)) \(task.unit)",
        "",  // Blank Price column
      ]
      
      _drawTableRow(data: rowData, at: currentY, height: rowHeight)
      currentY += rowHeight
    }
    
    currentY += spacing * 2  // Double spacing after last row
    drawText(
      "Total:  ____________________", font: UIFont.systemFont(ofSize: 14, weight: .semibold),
      alignment: .right, color: UIColor.black)
  }
  
  // Draws a list of tasks in a 2-column format
  func drawTasks(tasks: [LandscapingTask], images imagesDictionary: [UUID: [UIImage]]) {
    let columnSpacing: CGFloat = 20.0
    let columnWidth = (pageRect.width - (2 * margin) - columnSpacing) / 2
    
    for i in stride(from: 0, to: tasks.count, by: 2) {
      let leftTask = tasks[i]
      let leftTaskImages = imagesDictionary[leftTask.id] ?? []
      let leftHeight = calculateTaskHeight(task: leftTask, images: leftTaskImages, width: columnWidth)
      
      var rightHeight: CGFloat = 0
      if i + 1 < tasks.count {
        let rightTask = tasks[i + 1]
        let rightTaskImages = imagesDictionary[rightTask.id] ?? []
        rightHeight = calculateTaskHeight(task: rightTask, images: rightTaskImages, width: columnWidth)
      }
      
      let rowHeight = max(leftHeight, rightHeight)
      checkForPageBreak(addingHeight: rowHeight)
      
      let leftFrame = CGRect(x: margin, y: currentY, width: columnWidth, height: rowHeight)
      drawSingleTask(task: leftTask, images: leftTaskImages, in: leftFrame)
      
      if i + 1 < tasks.count {
        let rightTask = tasks[i + 1]
        let rightTaskImages = imagesDictionary[rightTask.id] ?? []
        let rightFrameX = margin + columnWidth + columnSpacing
        let rightFrame = CGRect(x: rightFrameX, y: currentY, width: columnWidth, height: rowHeight)

        drawSingleTask(task: rightTask, images: rightTaskImages, in: rightFrame)
      }
      currentY += rowHeight + spacing
    }
  }
  
  /// Draws a title with a large, bold font.
  func drawTitle(text: String, alignment: NSTextAlignment = .center) {
    let titleFont = UIFont.systemFont(ofSize: 24.0, weight: .bold)
    drawText(text, font: titleFont, alignment: alignment, color: .black)
  }
  
  /// Draws a paragraph with a standard body font.
  func drawParagraph(
    text: String, alignment: NSTextAlignment = .justified, fontSize: CGFloat = 12.0
  ) {
    let bodyFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
    
    // First, calculate the height of the text block
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    let attributes: [NSAttributedString.Key: Any] = [
      .font: bodyFont, .foregroundColor: UIColor.darkGray, .paragraphStyle: paragraphStyle,
    ]
    let attributedText = NSAttributedString(string: text, attributes: attributes)
    let availableWidth = pageRect.width - (2 * margin)
    let textHeight = attributedText.boundingRect(
      with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
      options: .usesLineFragmentOrigin, context: nil
    ).height
    
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
}
