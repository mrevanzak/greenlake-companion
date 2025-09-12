//
//  PDFBuilder + DrawHelpers.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 11/09/25.
//

import PDFKit

extension PDFBuilder {
  /// Draws a list of images that wrap to a new line if they exceed the page width.
  func _drawWrappingImageList(images: [UIImage], maxImageHeight: CGFloat = 120.0) {
    guard !images.isEmpty else { return }
    
    let imageSpacing: CGFloat = 8.0
    var totalGalleryHeight: CGFloat = 0
    var currentX: CGFloat = margin
    var rowMaxHeight: CGFloat = 0
    
    for image in images {
      let aspectRatio = image.size.width / image.size.height
      let scaledHeight = min(image.size.height, maxImageHeight)
      let scaledWidth = scaledHeight * aspectRatio
      
      if currentX + scaledWidth > pageRect.width - margin {
        totalGalleryHeight += rowMaxHeight + imageSpacing
        currentX = margin
        rowMaxHeight = 0
      }
      
      currentX += scaledWidth + imageSpacing
      rowMaxHeight = max(rowMaxHeight, scaledHeight)
    }
    totalGalleryHeight += rowMaxHeight
    
    checkForPageBreak(addingHeight: totalGalleryHeight)
    
    currentX = margin
    let startY = currentY
    
    for image in images {
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
    
    currentY = startY + totalGalleryHeight + spacing
  }
  
  /// Draws the key-value details section for a task.
  func _drawKeyValueDetails(for task: LandscapingTask, fontSize: CGFloat = 10.0) {
    let detailsFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
    let details: [(key: String, value: String)] = [
      ("Tanaman", task.plant_name),
      ("Lokasi", task.location),
      ("Ukuran", "\(String(format: "%.2f", task.size)) \(task.unit)"),
      ("Tenggat Waktu", dateFormatter.string(from: task.dueDate)),
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
      let keyText = NSAttributedString(
        string: detail.key, attributes: [.font: detailsFont, .foregroundColor: UIColor.gray])
      let valueText = NSAttributedString(
        string: detail.value, attributes: [.font: detailsFont, .foregroundColor: UIColor.black])
      
      let valueSize = valueText.size()
      let lineHeight = valueSize.height
      
      let keyRect = CGRect(x: margin, y: currentY, width: contentWidth / 2, height: lineHeight)
      keyText.draw(in: keyRect)
      
      let valueRect = CGRect(
        x: pageRect.width - margin - valueSize.width, y: currentY, width: valueSize.width,
        height: lineHeight)
      valueText.draw(in: valueRect)
      
      currentY += lineHeight + (spacing / 2)
    }
    // Add final spacing after the block
    currentY += spacing
  }
  
  func drawText(_ text: String, font: UIFont, alignment: NSTextAlignment = NSTextAlignment.center, color: UIColor = UIColor.black, rectLocation: CGRect? = nil) {
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
    
    checkForPageBreak(addingHeight: textHeight)
    
    let textRect = rectLocation ?? CGRect(x: margin, y: currentY, width: availableWidth, height: textHeight)
    attributedText.draw(in: textRect)
    
    currentY = textRect.maxY + spacing
  }
  
  func _drawSigningTemplate() {
    let topLabelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    let nameTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
    let signatureLineText = "____________________"
    
    // --- 1. Measurement Pass ---
    let topLabelHeight = "Mengetahui,".size(withAttributes: [.font: topLabelFont]).height
    let signatureLineHeight = signatureLineText.size(withAttributes: [.font: nameTitleFont]).height
    let nameTitleHeight = "Pengawas Lapangan".size(withAttributes: [.font: nameTitleFont]).height
    
    let verticalGap: CGFloat = 60.0
    let totalHeight = topLabelHeight + verticalGap + signatureLineHeight + nameTitleHeight + (spacing * 2)
    
    // --- 2. Page Break Check ---
    checkForPageBreak(addingHeight: totalHeight)
    
    // Add extra space before the template
    currentY += spacing * 2
    
    // --- 3. Drawing Pass ---
    let columnWidth = (pageRect.width - (2 * margin)) / 2
    let leftColumnX = margin
    let rightColumnX = margin + columnWidth
    
    // Draw "Mengetahui,"
    let topLabelY = currentY
    let leftTopLabelRect = CGRect(x: leftColumnX, y: topLabelY, width: columnWidth, height: topLabelHeight)
    let rightTopLabelRect = CGRect(x: rightColumnX, y: topLabelY, width: columnWidth, height: topLabelHeight)
    drawText("Mengetahui,", font: topLabelFont, rectLocation: leftTopLabelRect)
    drawText("Mengetahui,", font: topLabelFont, rectLocation: rightTopLabelRect)
    
    // Draw signature lines
    let signatureLineY = topLabelY + topLabelHeight + verticalGap
    let leftSigRect = CGRect(x: leftColumnX, y: signatureLineY, width: columnWidth, height: signatureLineHeight)
    let rightSigRect = CGRect(x: rightColumnX, y: signatureLineY, width: columnWidth, height: signatureLineHeight)
    drawText(signatureLineText, font: nameTitleFont, rectLocation: leftSigRect)
    drawText(signatureLineText, font: nameTitleFont, rectLocation: rightSigRect)
    
    // Draw name titles
    let nameTitleY = signatureLineY + signatureLineHeight
    let leftNameRect = CGRect(x: leftColumnX, y: nameTitleY, width: columnWidth, height: nameTitleHeight)
    let rightNameRect = CGRect(x: rightColumnX, y: nameTitleY, width: columnWidth, height: nameTitleHeight)
    drawText("Pengawas Lapangan", font: nameTitleFont, rectLocation: leftNameRect)
    drawText("City Management", font: nameTitleFont, rectLocation: rightNameRect)
    
    // Update the main Y cursor
    currentY = nameTitleY + nameTitleHeight + spacing
  }
  
  /// Draws text vertically centered within a cell's rectangle.
  func drawTextInCell(_ text: NSAttributedString, in rect: CGRect) {
    let padding: CGFloat = 5.0
    let textHeight = text.size().height
    let textY = rect.origin.y + (rect.height - textHeight) / 2
    let textRect = CGRect(
      x: rect.origin.x + padding,
      y: textY,
      width: rect.width - (2 * padding),
      height: textHeight)
    text.draw(in: textRect)
  }
  
  /// Draws the header row for the fines table at a specific Y position.
  func _drawTableHeader(at y: CGFloat, height: CGFloat) {
    let columnWidths = calculateColumnWidths()
    var currentX: CGFloat = margin
    
    // Draw gray background for the header
    let backgroundRect = CGRect(
      x: margin, y: y, width: pageRect.width - (2 * margin), height: height)
    UIColor.lightGray.withAlphaComponent(0.3).setFill()
    UIRectFill(backgroundRect)
    
    let headerTitles = ["No.", "Pekerjaan", "Tanggal", "Durasi", "Ukuran", "Denda"]
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
      .foregroundColor: UIColor.black,
    ]
    
    for (index, title) in headerTitles.enumerated() {
      let cellRect = CGRect(x: currentX, y: y, width: columnWidths[index], height: height)
      drawTextInCell(NSAttributedString(string: title, attributes: attributes), in: cellRect)
      currentX += columnWidths[index]
    }
  }
  
  /// Draws a single content row for the fines table.
  func _drawTableRow(data: [String], at y: CGFloat, height: CGFloat) {
    let columnWidths = calculateColumnWidths()
    var currentX: CGFloat = margin
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 9, weight: .regular),
      .foregroundColor: UIColor.darkGray,
    ]
    
    for (index, item) in data.enumerated() {
      let cellRect = CGRect(x: currentX, y: y, width: columnWidths[index], height: height)
      drawTextInCell(NSAttributedString(string: item, attributes: attributes), in: cellRect)
      currentX += columnWidths[index]
    }
    
    // Draw a bottom border for the row
    _drawHorizontalLineOnly(at: y + height)
  }
  
  /// Draws a horiozntal rule at a specific Y point (ignores default spacing)
  func _drawHorizontalLineOnly(at yPosition: CGFloat) {
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
  func drawSingleTask(task: LandscapingTask, images: [UIImage], in frame: CGRect) {
    let internalPadding: CGFloat = 10.0
    var contentY = frame.minY + internalPadding
    let contentX = frame.minX + internalPadding
    let contentWidth = frame.width - (2 * internalPadding)
    
    // MODIFIED: Use the passed-in 'images' array directly
    if !images.isEmpty {
      let imageSize = CGSize(width: 100, height: 100)
      var imageX = contentX
      for image in images.prefix(2) {
        let imageRect = CGRect(origin: CGPoint(x: imageX, y: contentY), size: imageSize)
        image.draw(in: imageRect)
        imageX += imageSize.width + (internalPadding / 2)
      }
      contentY += imageSize.height + spacing
    }
    
    // ... (Rest of this function is unchanged)
    let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    let attributedTitle = NSAttributedString(string: task.title, attributes: [.font: titleFont])
    let titleHeight = attributedTitle.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    let titleRect = CGRect(x: contentX, y: contentY, width: contentWidth, height: titleHeight)
    attributedTitle.draw(in: titleRect)
    contentY += titleHeight + (spacing / 2)
    
    let descriptionFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    let attributedDescription = NSAttributedString(string: task.description, attributes: [.font: descriptionFont, .foregroundColor: UIColor.darkGray])
    let descriptionHeight = attributedDescription.boundingRect(with: CGSize(width: contentWidth, height: .infinity), options: .usesLineFragmentOrigin, context: nil).height
    let descriptionRect = CGRect(x: contentX, y: contentY, width: contentWidth, height: descriptionHeight)
    attributedDescription.draw(in: descriptionRect)
    contentY += descriptionHeight + spacing
    
    let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    let details: [(key: String, value: String)] = [
      ("Tanaman", task.plant_name),
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
    
    let roundedPath = UIBezierPath(roundedRect: frame, cornerRadius: 8.0)
    roundedPath.lineWidth = 1.0
    UIColor.lightGray.setStroke()
    roundedPath.stroke()
  }
}
