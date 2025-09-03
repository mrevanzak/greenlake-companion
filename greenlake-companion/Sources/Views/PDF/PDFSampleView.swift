//
//  PDFSampleView.swift
//  greenlake-companion
//
//  Debug-only sample to generate and preview a PDF.
//  Created by Savio Enoson on 02/09/25.
//

import PDFKit
import SwiftUI

struct PDFSampleView: View {
  @State private var pdfPreview: PDFDataWrapper?

  var body: some View {
    VStack {
      Button("Generate and Preview PDF") {
        generatePDF()
      }
      .font(.title)
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .sheet(item: $pdfPreview) { pdfDataWrapper in
      NavigationView {
        PDFKitView(data: pdfDataWrapper.data)
          .navigationTitle("PDF Preview")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Done") { self.pdfPreview = nil }
            }
          }
      }
    }
  }

  private func generatePDF() {
    // Replace with real images or adjust names to match your asset catalog.
    guard let img1 = UIImage(named: "img1"),
      let img2 = UIImage(named: "img2"),
      let img3 = UIImage(named: "img3"),
      let img4 = UIImage(named: "img4")
    else {
      print(
        "⚠️ Error: Could not load one or more images from assets. Make sure 'img1' through 'img4' exist."
      )
      return
    }

    let reportTitle = "Quarterly Progress Report"
    let longParagraph = """
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla.
      """

    let creator = PDFBuilder()
    let pdfData = creator.createPDF { pdf in
      pdf.drawTitle(text: reportTitle)
      pdf.drawParagraph(
        text:
          "This document outlines the key achievements and milestones from the past quarter. We have seen significant growth in user engagement and market penetration."
      )
      pdf.drawImage(image: img1, alignment: .center)
      pdf.drawParagraph(text: longParagraph)
      pdf.drawHorizontalRule()
      pdf.drawTitle(text: "Image Gallery", alignment: .left)
      pdf.drawParagraph(
        text:
          "A selection of images from recent company events and product launches. The following images are aligned to the center as a group."
      )
      pdf.drawImageList(images: [img2, img3, img4], alignment: .center)
      pdf.drawParagraph(text: "End of report.", alignment: .center)
    }

    self.pdfPreview = PDFDataWrapper(data: pdfData)
  }
}

#Preview {
  PDFSampleView()
}
