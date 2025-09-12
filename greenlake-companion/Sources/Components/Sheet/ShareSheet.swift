//
//  ShareSheet.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 11/09/25.
//


import SwiftUI
import UIKit

/// A UIViewControllerRepresentable that wraps UIActivityViewController to be used in SwiftUI.
struct ShareSheet: UIViewControllerRepresentable {
    // The items to share (in our case, it will be the URL of the PDF file)
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
