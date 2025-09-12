//
//  PDFKitView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import PDFKit
import SwiftUI

/// A SwiftUI wrapper around `PDFView` for displaying PDF `Data`.
struct PDFKitView: UIViewRepresentable {
  let data: Data
  private let scaleFactor = 0.85
  
  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    pdfView.autoScales = false
    DispatchQueue.main.async {
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit * scaleFactor
    }
    pdfView.backgroundColor = .clear
    return pdfView
  }
  
  func updateUIView(_ pdfView: PDFView, context: Context) {
    if pdfView.document?.dataRepresentation() != data {
      pdfView.document = PDFDocument(data: data)
      DispatchQueue.main.async {
          pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit * scaleFactor
      }
      pdfView.goToFirstPage(nil)
    }
  }
}

/// Identifiable wrapper for PDF data, handy for sheet presentations.
struct PDFDataWrapper: Identifiable, Equatable {
  let id = UUID()
  let data: Data
  
  func getURL() -> URL? {
    let tempURL = URL.temporaryDirectory.appending(path: "report-\(id.uuidString).pdf")
    do {
      try data.write(to: tempURL)
      return tempURL
    } catch {
      print("Error saving PDF to temp file: \(error)")
      return nil
    }
  }
}
