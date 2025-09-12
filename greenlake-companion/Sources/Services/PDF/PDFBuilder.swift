//
//  PDFBuilder.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import PDFKit

// A custom enum for image alignment for better clarity
enum ImageAlignment {
  case left, center, right
}

enum PDFGenerationError: Error {
  case invalidImageData
  case invalidGenerationSequence
  case networkError(Error)
}

class PDFBuilder {
  var timelinesByTaskID: [UUID: [TaskChangelog]] = [:]
  
  /// The current vertical position on the page.
  var currentY: CGFloat = 0
  
  /// The graphics context of the PDF, accessible during the build process.
  /// This is necessary for starting new pages.
  var context: UIGraphicsPDFRendererContext?
  
  let pageRect: CGRect
  let renderer: UIGraphicsPDFRenderer
  
  // Constants for layout
  let margin: CGFloat = 36.0
  let spacing: CGFloat = 12.0
  
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
}
