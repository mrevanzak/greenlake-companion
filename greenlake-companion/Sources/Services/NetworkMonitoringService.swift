//
//  NetworkMonitoringService.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation
import Network

/// Network monitoring service for tracking connectivity and performance
class NetworkMonitoringService: ObservableObject {
  // MARK: - Published Properties

  @Published var isConnected = false
  @Published var connectionType: ConnectionType = .unknown
  @Published var networkQuality: NetworkQuality = .unknown

  // MARK: - Private Properties

  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "NetworkMonitoring")
  private var requestMetrics: [String: RequestMetric] = [:]

  // MARK: - Singleton

  static let shared = NetworkMonitoringService()

  // MARK: - Initialization

  private init() {
    setupNetworkMonitoring()
  }

  deinit {
    monitor.cancel()
  }

  // MARK: - Public Methods

  /// Start monitoring network connectivity
  func startMonitoring() {
    monitor.start(queue: queue)
  }

  /// Stop monitoring network connectivity
  func stopMonitoring() {
    monitor.cancel()
  }

  /// Record a network request metric
  /// - Parameters:
  ///   - endpoint: The API endpoint that was called
  ///   - duration: Request duration in seconds
  ///   - success: Whether the request was successful
  ///   - error: Any error that occurred
  func recordRequest(
    endpoint: String,
    duration: TimeInterval,
    success: Bool,
    error: Error? = nil
  ) {
    let metric = RequestMetric(
      endpoint: endpoint,
      duration: duration,
      success: success,
      error: error,
      timestamp: Date()
    )

    // Store metric with endpoint as key
    requestMetrics[endpoint] = metric

    // Update network quality based on recent metrics
    updateNetworkQuality()
  }

  /// Get performance metrics for a specific endpoint
  /// - Parameter endpoint: The endpoint to get metrics for
  /// - Returns: Request metric if available
  func getMetrics(for endpoint: String) -> RequestMetric? {
    return requestMetrics[endpoint]
  }

  /// Get overall network performance summary
  /// - Returns: Network performance summary
  func getPerformanceSummary() -> NetworkPerformanceSummary {
    let allMetrics = Array(requestMetrics.values)
    let successfulRequests = allMetrics.filter { $0.success }
    let failedRequests = allMetrics.filter { !$0.success }

    let averageResponseTime =
      allMetrics.isEmpty
      ? 0 : allMetrics.map { $0.duration }.reduce(0, +) / Double(allMetrics.count)
    let successRate =
      allMetrics.isEmpty ? 0 : Double(successfulRequests.count) / Double(allMetrics.count)

    return NetworkPerformanceSummary(
      totalRequests: allMetrics.count,
      successfulRequests: successfulRequests.count,
      failedRequests: failedRequests.count,
      averageResponseTime: averageResponseTime,
      successRate: successRate,
      lastUpdated: Date()
    )
  }

  // MARK: - Private Methods

  private func setupNetworkMonitoring() {
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        self?.updateConnectionStatus(path)
      }
    }

    startMonitoring()
  }

  private func updateConnectionStatus(_ path: NWPath) {
    isConnected = path.status == .satisfied

    // Determine connection type
    if path.usesInterfaceType(.wifi) {
      connectionType = .wifi
    } else if path.usesInterfaceType(.cellular) {
      connectionType = .cellular
    } else if path.usesInterfaceType(.wiredEthernet) {
      connectionType = .ethernet
    } else if path.usesInterfaceType(.loopback) {
      connectionType = .loopback
    } else {
      connectionType = .unknown
    }
  }

  private func updateNetworkQuality() {
    let summary = getPerformanceSummary()

    // Determine network quality based on success rate and response time
    if summary.successRate >= 0.95 && summary.averageResponseTime < 1.0 {
      networkQuality = .excellent
    } else if summary.successRate >= 0.90 && summary.averageResponseTime < 2.0 {
      networkQuality = .good
    } else if summary.successRate >= 0.80 && summary.averageResponseTime < 5.0 {
      networkQuality = .fair
    } else if summary.successRate >= 0.70 {
      networkQuality = .poor
    } else {
      networkQuality = .veryPoor
    }
  }
}

// MARK: - Supporting Types

/// Network connection types
enum ConnectionType: String, CaseIterable {
  case wifi = "WiFi"
  case cellular = "Cellular"
  case ethernet = "Ethernet"
  case loopback = "Loopback"
  case unknown = "Unknown"

  var icon: String {
    switch self {
    case .wifi:
      return "wifi"
    case .cellular:
      return "antenna.radiowaves.left.and.right"
    case .ethernet:
      return "cable.connector"
    case .loopback:
      return "network"
    case .unknown:
      return "questionmark.circle"
    }
  }
}

/// Network quality levels
enum NetworkQuality: String, CaseIterable {
  case excellent = "Excellent"
  case good = "Good"
  case fair = "Fair"
  case poor = "Poor"
  case veryPoor = "Very Poor"
  case unknown = "Unknown"

  var color: String {
    switch self {
    case .excellent:
      return "green"
    case .good:
      return "blue"
    case .fair:
      return "yellow"
    case .poor:
      return "orange"
    case .veryPoor:
      return "red"
    case .unknown:
      return "gray"
    }
  }
}

/// Individual request metric
struct RequestMetric {
  let endpoint: String
  let duration: TimeInterval
  let success: Bool
  let error: Error?
  let timestamp: Date
}

/// Network performance summary
struct NetworkPerformanceSummary {
  let totalRequests: Int
  let successfulRequests: Int
  let failedRequests: Int
  let averageResponseTime: TimeInterval
  let successRate: Double
  let lastUpdated: Date
}
