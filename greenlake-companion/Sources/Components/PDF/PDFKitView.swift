//
//  PDFKitView.swift
//  greenlake-companion
//
//  Moved to Components/PDF and trimmed to the SwiftUI representable only.
//  Created by Savio Enoson on 02/09/25.
//

import PDFKit
import SwiftUI

/// A SwiftUI wrapper around `PDFView` for displaying PDF `Data`.
struct PDFKitView: UIViewRepresentable {
  let data: Data

  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    pdfView.document = PDFDocument(data: data)
    pdfView.autoScales = true
    return pdfView
  }

  func updateUIView(_ uiView: PDFView, context: Context) {
    // No dynamic updates needed for now
  }
}

/// Identifiable wrapper for PDF data, handy for sheet presentations.
struct PDFDataWrapper: Identifiable {
  let id = UUID()
  let data: Data
}
