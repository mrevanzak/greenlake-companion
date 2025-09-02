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
  private var currentY: CGFloat = 0
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
      context.beginPage()
      self.currentY = margin  // Start drawing from the top margin
      build(self)
    }
    return data
  }

  // MARK: - Drawing Functions

  /// Draws a title with a large, bold font.
  func drawTitle(text: String, alignment: NSTextAlignment = .center) {
    let titleFont = UIFont.systemFont(ofSize: 28.0, weight: .bold)
    drawText(text, font: titleFont, alignment: alignment, color: .black)
  }

  /// Draws a paragraph with a standard body font.
  func drawParagraph(text: String, alignment: NSTextAlignment = .justified) {
    let bodyFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    drawText(text, font: bodyFont, alignment: alignment, color: .darkGray)
  }

  /// Draws a single, scaled image.
  func drawImage(image: UIImage, alignment: ImageAlignment = .center) {
    let maxWidth = pageRect.width - (2 * margin)
    let maxHeight = pageRect.height * 0.4  // Max 40% of page height

    let aspectRatio = min(maxWidth / image.size.width, maxHeight / image.size.height)
    let scaledWidth = image.size.width * aspectRatio
    let scaledHeight = image.size.height * aspectRatio

    var imageX: CGFloat
    switch alignment {
    case .left:
      imageX = margin
    case .center:
      imageX = (pageRect.width - scaledWidth) / 2.0
    case .right:
      imageX = pageRect.width - scaledWidth - margin
    }

    let imageRect = CGRect(x: imageX, y: currentY, width: scaledWidth, height: scaledHeight)
    image.draw(in: imageRect)

    // Update Y position
    currentY = imageRect.maxY + spacing
  }

  /// Draws a list of images horizontally.
  func drawImageList(images: [UIImage], alignment: ImageAlignment = .center) {
    guard !images.isEmpty else { return }

    let availableWidth = pageRect.width - (2 * margin)
    let padding: CGFloat = 10.0
    let totalPadding = padding * CGFloat(images.count - 1)
    let itemWidth = (availableWidth - totalPadding) / CGFloat(images.count)

    guard itemWidth > 0 else {
      print("Not enough space to draw images.")
      return
    }

    var maxItemHeight: CGFloat = 0
    var scaledImages = [(image: UIImage, rect: CGRect)]()

    // First pass: Scale all images and find max height
    for image in images {
      let aspectRatio = itemWidth / image.size.width
      let scaledHeight = image.size.height * aspectRatio
      maxItemHeight = max(maxItemHeight, scaledHeight)
    }

    let startX: CGFloat
    let totalContentWidth = (itemWidth * CGFloat(images.count)) + totalPadding
    switch alignment {
    case .left:
      startX = margin
    case .center:
      startX = (pageRect.width - totalContentWidth) / 2.0
    case .right:
      startX = pageRect.width - totalContentWidth - margin
    }

    var currentX = startX

    // Second pass: Draw the images
    for image in images {
      let aspectRatio = itemWidth / image.size.width
      let scaledHeight = image.size.height * aspectRatio

      // Vertically center smaller images in the row
      let imageY = currentY + (maxItemHeight - scaledHeight) / 2.0

      let imageRect = CGRect(x: currentX, y: imageY, width: itemWidth, height: scaledHeight)
      image.draw(in: imageRect)
      currentX += itemWidth + padding
    }

    // Update Y position
    currentY += maxItemHeight + spacing
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

  // MARK: - Private Helper

  /// A generic helper function to draw text.
  private func drawText(_ text: String, font: UIFont, alignment: NSTextAlignment, color: UIColor) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraphStyle,
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
}
