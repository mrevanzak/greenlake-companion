//
//  CustomTileOverlay.swift
//  greenlake-companion
//
//  Created by AI Assistant on 12/01/25.
//

import Foundation
import MapKit
import UIKit
import os.log

/// Custom tile overlay service for loading specialized map tiles with fallback support
/// Follows the service-oriented architecture pattern, separating tile logic from view components
/// Optimized for performance with caching and efficient fallback strategies
final class CustomTileOverlay: MKTileOverlay {

  // MARK: - Properties

  /// Base URL for external tile server (optional)
  private let tileBaseURL: String?

  /// Name of the fallback tile asset in the bundle
  private let fallbackTileName: String

  /// Cache for fallback URLs to avoid repeated file operations
  private let fallbackURLCache = NSCache<NSString, NSURL>()

  /// Logger for debugging and monitoring
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "greenlake-companion",
    category: "CustomTileOverlay")

  /// Queue for background tile processing
  private let tileProcessingQueue = DispatchQueue(
    label: "com.greenlake.tile-processing",
    qos: .utility)

  // MARK: - Constants

  /// Asset names for fallback tiles in order of preference
  private static let fallbackAssetNames = ["parchment", "placeholder"]

  /// Bundle fallback tile names
  private static let bundleFallbackNames = ["greenlake-default", "parchment"]

  /// Transparent PNG data URL (cached as static)
  private static let emptyTileDataURL: URL = {
    let transparentPNG =
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI/hFmXWQAAAABJRU5ErkJggg=="
    let dataURLString = "data:image/png;base64,\(transparentPNG)"
    return URL(string: dataURLString)!
  }()

  // MARK: - Initialization

  /// Initialize custom tile overlay with optional external URL and fallback tile
  /// - Parameters:
  ///   - tileBaseURL: Optional base URL for external tile server
  ///   - fallbackTile: Name of fallback tile asset in bundle
  init(tileBaseURL: String? = nil, fallbackTile: String = "default-tile") {
    self.tileBaseURL = tileBaseURL
    self.fallbackTileName = fallbackTile
    super.init(urlTemplate: nil)

    setupTileOverlayProperties()
    configureCaching()
  }

  // MARK: - Private Setup Methods

  /// Configure tile overlay properties and zoom constraints
  private func setupTileOverlayProperties() {
    // Enable replacement of default map content
    canReplaceMapContent = true

    // Set zoom level constraints to prevent loading billions of non-existent tiles
    minimumZ = 13  // Minimum zoom level with custom tiles
    maximumZ = 16  // Maximum zoom level with custom tiles
  }

  /// Configure caching settings for optimal performance
  private func configureCaching() {
    fallbackURLCache.countLimit = 20  // Limit cache size
    fallbackURLCache.totalCostLimit = 1024 * 1024 * 5  // 5MB limit
  }

  // MARK: - MKTileOverlay Override

  /// Resolve tile URL using hierarchical loading strategy: bundle -> external -> fallback
  /// - Parameter path: Tile path containing x, y, z coordinates
  /// - Returns: URL for the requested tile
  override func url(forTilePath path: MKTileOverlayPath) -> URL {
    // Optimized logging - only in debug builds
    #if DEBUG
      logger.debug("Requested tile z:\(path.z) x:\(path.x) y:\(path.y)")
    #endif

    // First priority: Try to load custom tile from bundle
    if let bundleTileURL = loadTileFromBundle(path: path) {
      return bundleTileURL
    }

    // Second priority: Try external URL if provided
    if let externalURL = tryExternalURL(for: path) {
      return externalURL
    }

    // Final fallback: Return cached or computed fallback tile
    return getCachedFallbackURL()
  }

  // MARK: - Private Helper Methods

  /// Load tile from app bundle using standard tile directory structure
  /// - Parameter path: Tile path containing x, y, z coordinates
  /// - Returns: URL if tile exists in bundle, nil otherwise
  private func loadTileFromBundle(path: MKTileOverlayPath) -> URL? {
    return Bundle.main.url(
      forResource: "\(path.y)",
      withExtension: "png",
      subdirectory: "tiles/\(path.z)/\(path.x)",
      localization: nil
    )
  }

  /// Try to create external URL for tile
  /// - Parameter path: Tile path containing x, y, z coordinates
  /// - Returns: Valid URL if external base URL is configured, nil otherwise
  private func tryExternalURL(for path: MKTileOverlayPath) -> URL? {
    guard let baseURL = tileBaseURL else { return nil }

    let tileURLString = "\(baseURL)/\(path.z)/\(path.x)/\(path.y).png"
    return URL(string: tileURLString)
  }

  /// Get cached fallback URL or compute if not cached
  /// - Returns: Fallback tile URL (guaranteed to be valid)
  private func getCachedFallbackURL() -> URL {
    let cacheKey = "fallback_\(fallbackTileName)" as NSString

    // Check cache first
    if let cachedURL = fallbackURLCache.object(forKey: cacheKey) as URL? {
      return cachedURL
    }

    // Compute fallback URL and cache it
    let fallbackURL = computeFallbackURL()
    fallbackURLCache.setObject(fallbackURL as NSURL, forKey: cacheKey)

    return fallbackURL
  }

  /// Compute fallback tile URL using modern asset catalog approach
  /// - Returns: URL for fallback tile, with graceful degradation through assets and bundle
  private func computeFallbackURL() -> URL {
    // First: Try to load from asset catalog using UIImage
    if let assetURL = loadFallbackFromAssets() {
      return assetURL
    }

    // Second: Try specified fallback tile from bundle
    if let customFallbackURL = loadCustomFallbackFromBundle() {
      return customFallbackURL
    }

    // Third: Try standard bundle fallbacks
    if let bundleFallbackURL = loadStandardBundleFallbacks() {
      return bundleFallbackURL
    }

    // Ultimate fallback: return static empty tile data URL
    logger.warning("Using empty tile fallback - no tile assets found")
    return Self.emptyTileDataURL
  }

  /// Load fallback tile from Assets.xcassets using UIImage
  /// - Returns: Temporary file URL for asset image, nil if not found
  private func loadFallbackFromAssets() -> URL? {
    // Include custom fallback name in search
    let assetNames = [fallbackTileName] + Self.fallbackAssetNames

    for assetName in assetNames {
      if let image = UIImage(named: assetName) {
        return createTemporaryImageURL(from: image, named: assetName)
      }
    }

    return nil
  }

  /// Load custom fallback tile from bundle
  /// - Returns: Bundle URL for custom fallback tile, nil if not found
  private func loadCustomFallbackFromBundle() -> URL? {
    Bundle.main.url(
      forResource: fallbackTileName,
      withExtension: "png",
      subdirectory: "tiles",
      localization: nil
    )
  }

  /// Load standard fallback tiles from bundle
  /// - Returns: Bundle URL for standard fallback tile, nil if not found
  private func loadStandardBundleFallbacks() -> URL? {
    for tileName in Self.bundleFallbackNames {
      if let tileURL = Bundle.main.url(
        forResource: tileName,
        withExtension: "png",
        subdirectory: "tiles",
        localization: nil
      ) {
        return tileURL
      }
    }
    return nil
  }

  /// Create a temporary file URL from UIImage for use with MKTileOverlay
  /// - Parameters:
  ///   - image: UIImage from asset catalog
  ///   - name: Name for the temporary file
  /// - Returns: Temporary file URL, nil if creation fails
  private func createTemporaryImageURL(from image: UIImage, named name: String) -> URL? {
    guard let imageData = image.pngData() else {
      logger.error("Failed to convert UIImage to PNG data for asset: \(name)")
      return nil
    }

    let tempDirectory = FileManager.default.temporaryDirectory
    let filename = "tile_\(name)_\(UUID().uuidString).png"
    let tempFileURL = tempDirectory.appendingPathComponent(filename)

    do {
      try imageData.write(to: tempFileURL)
      logger.debug("Created temporary tile file: \(filename)")
      return tempFileURL
    } catch {
      logger.error(
        "Failed to write temporary tile file for asset \(name): \(error.localizedDescription)")
      return nil
    }
  }
}

// MARK: - Cache Management Extension

extension CustomTileOverlay {
  /// Clear fallback URL cache to free memory
  func clearFallbackCache() {
    fallbackURLCache.removeAllObjects()
    logger.debug("Cleared fallback URL cache")
  }

  /// Get cache statistics for monitoring
  var cacheStatistics: (count: Int, totalCost: Int) {
    (count: fallbackURLCache.countLimit, totalCost: fallbackURLCache.totalCostLimit)
  }
}
