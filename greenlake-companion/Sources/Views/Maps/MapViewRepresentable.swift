//
//  MapViewRepresentable.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation
import MapKit
import SwiftUI

/// SwiftUI wrapper for MKMapView
struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var plantManager: PlantManager
    
    // MARK: - Initialization
    
    /// Initialize MapViewRepresentable
    /// - Parameters:
    ///   - locationManager: Location manager for user location tracking
    ///   - plantManager: Centralized plant state manager
    init(
        locationManager: LocationManager,
        plantManager: PlantManager
    ) {
        self.locationManager = locationManager
        self.plantManager = plantManager
    }
    
    // MARK: - UIViewRepresentable Implementation
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        // Set delegate for map interactions
        mapView.delegate = context.coordinator
        
        // Configure map appearance
        configureMapAppearance(mapView)
        
        // Configure user interaction
        configureUserInteraction(mapView)
        
        // Set initial region
        setupInitialRegion(mapView)
        
        // Add long press gesture recognizer
        addLongPressGesture(to: mapView, context: context)
        
        // Add tap gesture recognizer for path drawing
        addTapGesture(for: mapView, context: context)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update annotations when plants change
        updateAnnotations(on: mapView)
        
        // Update user location tracking if needed
        // if let location = locationManager.location {
        //   let region = MKCoordinateRegion(
        //     center: location.coordinate,
        //     span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //   )
        //   mapView.setRegion(region, animated: true)
        // }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Private Configuration Methods
    
    /// Configure map visual appearance settings
    private func configureMapAppearance(_ mapView: MKMapView) {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.mapType = .standard
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        
        mapView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
    
    /// Configure user interaction capabilities
    private func configureUserInteraction(_ mapView: MKMapView) {
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
    }
    
    /// Set up the initial map region
    private func setupInitialRegion(_ mapView: MKMapView) {
        mapView.setRegion(MapConstants.initialRegion, animated: false)
        
        // Set camera boundary to limit user navigation area
        setCameraBoundary(on: mapView)
    }
    
    /// Set camera boundary to limit the area where users can navigate
    private func setCameraBoundary(on mapView: MKMapView) {
        mapView.cameraBoundary = MapConstants.cameraBoundary
    }
    
    /// Add long press gesture recognizer to the map
    private func addLongPressGesture(to mapView: MKMapView, context: Context) {
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(_:))
        )
        longPressGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    /// Add tap gesture recognizer to the map for path drawing
    private func addTapGesture(for mapView: MKMapView, context: Context) {
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePathTap(_:))
        )
        mapView.addGestureRecognizer(tapGesture)
    }
    
    /// Update map annotations when plants change
    private func updateAnnotations(on mapView: MKMapView) {
        // Remove existing annotations
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Remove existing overlays
        let existingOverlays = mapView.overlays
        mapView.removeOverlays(existingOverlays)
        
        // Add new plant annotations (only for tree-type plants)
        let treeAnnotations = plantManager.plants
            .filter { $0.type == .tree }
            .map { PlantAnnotation(plant: $0) }
        mapView.addAnnotations(treeAnnotations)
        
        // Add tree radius overlays
        let treeOverlays = plantManager.plants
            .compactMap { plant -> MKCircle? in
                guard plant.type == .tree, let radius = plant.radius else { return nil }
                return MKCircle(center: plant.location, radius: radius)
            }
        
        print("🌳 Creating \(treeOverlays.count) tree overlays")
        mapView.addOverlays(treeOverlays)
        
        // Add path-based polygon overlays for non-tree plants
        let pathOverlays = plantManager.plants
            .compactMap { plant -> MKOverlay? in
                guard plant.type != .tree, let path = plant.path else { return nil }
                
                // Use MKPolyline for paths with < 3 points, MKPolygon for >= 3 points
                if path.count < 3 {
                    return MKPolyline(coordinates: path, count: path.count)
                } else {
                    return MKPolygon(coordinates: path, count: path.count)
                }
            }
        
        print("🌿 Creating \(pathOverlays.count) path overlays")
        mapView.addOverlays(pathOverlays)
        
        // Add temporary plant annotation if exists (only for tree-type plants)
        if let tempPlant = plantManager.temporaryPlant, tempPlant.type == .tree {
            let tempAnnotation = PlantAnnotation(plant: tempPlant)
            mapView.addAnnotation(tempAnnotation)
            
            // Add temporary plant radius overlay if it's a tree
            if tempPlant.type == .tree, let radius = tempPlant.radius {
                let tempOverlay = MKCircle(center: tempPlant.location, radius: radius)
                print("🌱 Adding temporary plant overlay with radius: \(radius)m")
                mapView.addOverlay(tempOverlay)
            }
            
            // Add temporary plant path overlay if it's a non-tree with path
            if tempPlant.type != .tree, let path = tempPlant.path {
                let tempPathOverlay: MKOverlay
                if path.count < 3 {
                    tempPathOverlay = MKPolyline(coordinates: path, count: path.count)
                } else {
                    tempPathOverlay = MKPolygon(coordinates: path, count: path.count)
                }
                print("🌱 Adding temporary plant path overlay with \(path.count) points")
                mapView.addOverlay(tempPathOverlay)
            }
        }
        
        // Add current path drawing overlay if in path drawing mode
        if plantManager.isDrawingPath {
            let currentPathOverlay: MKOverlay
            if plantManager.currentPathPoints.count < 3 {
                currentPathOverlay = MKPolyline(
                    coordinates: plantManager.currentPathPoints, count: plantManager.currentPathPoints.count)
            } else {
                currentPathOverlay = MKPolygon(
                    coordinates: plantManager.currentPathPoints, count: plantManager.currentPathPoints.count)
            }
            print(
                "✏️ Adding current path drawing overlay with \(plantManager.currentPathPoints.count) points")
            mapView.addOverlay(currentPathOverlay)
        }
    }
}

// MARK: - Coordinator for MKMapViewDelegate

extension MapViewRepresentable {
    /// Coordinator class implementing MKMapViewDelegate
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var isSelectingPlant = false
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        // MARK: - Map Centering Methods
        
        /// Center the map on a selected plant with appropriate zoom level
        /// - Parameters:
        ///   - plant: The plant instance to center on
        ///   - mapView: The map view to center
        private func centerMapOnPlant(_ plant: PlantInstance, in mapView: MKMapView) {
            // Calculate zoom span based on plant type
            let span: MKCoordinateSpan
            switch plant.type {
            case .tree:
                // Trees need closer zoom to show radius overlays clearly
                span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)  // ~200m
            case .bush, .groundCover:
                // Smaller plants get overview zoom for area context
                span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)  // ~500m
            }
            
            // Create region centered on plant location
            let region = MKCoordinateRegion(center: plant.location, span: span)
            
            // Constrain region to map boundaries
            let constrainedRegion = constrainRegionToBoundaries(region)
            
            // Center map with smooth animation
            mapView.setVisibleMapRect(
                MKMapRectForCoordinateRegion(constrainedRegion),
                edgePadding: .init(top: 0, left: SheetConstants.width, bottom: 0, right: 0),
                animated: true
            )
            
            // Provide haptic feedback for successful centering
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        /// Constrain a region to stay within the map's boundary limits
        /// - Parameter region: The region to constrain
        /// - Returns: A region that respects the boundary constraints
        private func constrainRegionToBoundaries(_ region: MKCoordinateRegion) -> MKCoordinateRegion {
            let boundaryRegion = MapConstants.boundaryRegion
            
            // Calculate the minimum and maximum allowed coordinates
            let minLat = boundaryRegion.center.latitude - boundaryRegion.span.latitudeDelta / 2
            let maxLat = boundaryRegion.center.latitude + boundaryRegion.span.latitudeDelta / 2
            let minLng = boundaryRegion.center.longitude - boundaryRegion.span.longitudeDelta / 2
            let maxLng = boundaryRegion.center.longitude + boundaryRegion.span.longitudeDelta / 2
            
            // Constrain the center coordinates to stay within boundaries
            let constrainedLat = max(minLat, min(maxLat, region.center.latitude))
            let constrainedLng = max(minLng, min(maxLng, region.center.longitude))
            
            // Ensure the span doesn't exceed boundary limits
            let maxAllowedLatSpan = boundaryRegion.span.latitudeDelta
            let maxAllowedLngSpan = boundaryRegion.span.longitudeDelta
            
            let constrainedLatSpan = min(region.span.latitudeDelta, maxAllowedLatSpan)
            let constrainedLngSpan = min(region.span.longitudeDelta, maxAllowedLngSpan)
            
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: constrainedLat,
                    longitude: constrainedLng
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: constrainedLatSpan,
                    longitudeDelta: constrainedLngSpan
                )
            )
        }
        
        /// Convert MKCoordinateRegion to MKMapRect
        /// - Parameter region: The coordinate region to convert
        /// - Returns: The corresponding map rect
        private func MKMapRectForCoordinateRegion(_ region: MKCoordinateRegion) -> MKMapRect {
            let a = MKMapPoint(
                CLLocationCoordinate2D(
                    latitude: region.center.latitude + region.span.latitudeDelta / 2,
                    longitude: region.center.longitude - region.span.longitudeDelta / 2
                ))
            let b = MKMapPoint(
                CLLocationCoordinate2D(
                    latitude: region.center.latitude - region.span.latitudeDelta / 2,
                    longitude: region.center.longitude + region.span.longitudeDelta / 2
                ))
            return MKMapRect(
                x: min(a.x, b.x),
                y: min(a.y, b.y),
                width: abs(a.x - b.x),
                height: abs(a.y - b.y)
            )
        }
        
        // MARK: - Long Press Handling
        
        /// Handle long press gesture to add new plants
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Create a temporary plant instead of immediately saving
            parent.plantManager.createTemporaryPlant(at: coordinate)
            
            // Center map on the selected plant
            if let temporaryPlant = parent.plantManager.temporaryPlant {
                centerMapOnPlant(temporaryPlant, in: mapView)
            }
            
            // Provide haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        /// Handle tap gesture for path drawing
        @objc func handlePathTap(_ gesture: UITapGestureRecognizer) {
            guard parent.plantManager.isDrawingPath else { return }
            
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            parent.plantManager.addPathPoint(coordinate)
        }
        
        // MARK: - MKMapViewDelegate
        
        /// Configure annotation views for plants
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize user location annotation
            guard !(annotation is MKUserLocation) else { return nil }
            
            // Check if this is one of our plant annotations
            guard let plantAnno = annotation as? PlantAnnotation else { return nil }
            
            let identifier = "PlantAnnotation"
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // Configure the pin appearance
            if plantAnno.isTemporary {
                // Temporary plants get a different appearance
                annotationView.pinTintColor = .systemOrange
                annotationView.alpha = 0.7
                annotationView.canShowCallout = false
            } else {
                // Permanent plants get normal appearance
                switch plantAnno.plant.type {
                case .tree: annotationView.pinTintColor = .systemGreen
                case .groundCover: annotationView.pinTintColor = .systemTeal
                case .bush: annotationView.pinTintColor = .systemMint
                }
                annotationView.canShowCallout = true
                annotationView.calloutOffset = CGPoint(x: 0, y: -4)
            }
            
            // Add a detail disclosure button to the callout (only for permanent plants)
            if !plantAnno.isTemporary {
                let detailButton = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = detailButton
            }
            
            return annotationView
        }
        
        /// Handle tap on annotation callout accessory
        func mapView(
            _ mapView: MKMapView, annotationView view: MKAnnotationView,
            calloutAccessoryControlTapped control: UIControl
        ) {
            guard let plantAnno = view.annotation as? PlantAnnotation else { return }
            
            // Don't allow selection of temporary plants
            guard !plantAnno.isTemporary else { return }
            
            // Set the selected plant by resolving back to value model
            if let plant = parent.plantManager.plants.first(where: { $0.id == plantAnno.id }) {
                isSelectingPlant = true
                parent.plantManager.selectPlant(plant)
                
                // Center map on the selected plant
                centerMapOnPlant(plant, in: mapView)
                
                // Reset the flag after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isSelectingPlant = false
                }
            }
            
            // Provide haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        /// Handle selection of annotations
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let plantAnno = view.annotation as? PlantAnnotation else { return }
            
            // Don't allow selection of temporary plants
            guard !plantAnno.isTemporary else { return }
            
            if let plant = parent.plantManager.plants.first(where: { $0.id == plantAnno.id }) {
                isSelectingPlant = true
                parent.plantManager.selectPlant(plant)
                
                // Center map on the selected plant
                centerMapOnPlant(plant, in: mapView)
                
                // Reset the flag after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isSelectingPlant = false
                }
            }
        }
        
        /// Handle deselection of annotations
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            // Prevent deselection if we're in the middle of selecting a plant
            guard !isSelectingPlant else { return }
            
            // Only clear selection if we're not currently selecting
            parent.plantManager.selectPlant(nil)
        }
        
        /// Configure overlay renderers for tree radius circles, path polygons, and polylines
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            print("🎨 Rendering overlay: \(type(of: overlay))")
            
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.6)
                renderer.lineWidth = 2.0
                print("🌿 Created circle renderer with radius: \(circle.radius)m")
                return renderer
            }
            
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                // Check if this is a current path drawing overlay
                if parent.plantManager.isDrawingPath
                    && polyline.pointCount == parent.plantManager.currentPathPoints.count
                {
                    // Current path drawing gets a different style
                    renderer.strokeColor = UIColor.systemOrange.withAlphaComponent(0.9)
                    renderer.lineWidth = 3.0
                    print(
                        "✏️ Created current path drawing polyline renderer with \(polyline.pointCount) points")
                } else {
                    // Existing path overlays get the standard style
                    renderer.strokeColor = UIColor.systemTeal.withAlphaComponent(0.8)
                    renderer.lineWidth = 2.0
                    print("🌿 Created polyline renderer with \(polyline.pointCount) points")
                }
                
                return renderer
            }
            
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                
                // Check if this is a current path drawing overlay
                if parent.plantManager.isDrawingPath
                    && polygon.pointCount == parent.plantManager.currentPathPoints.count
                {
                    // Current path drawing gets a different style
                    renderer.fillColor = UIColor.systemOrange.withAlphaComponent(0.2)
                    renderer.strokeColor = UIColor.systemOrange.withAlphaComponent(0.9)
                    renderer.lineWidth = 3.0
                    print("✏️ Created current path drawing renderer with \(polygon.pointCount) points")
                } else {
                    // Existing path overlays get the standard style
                    renderer.fillColor = UIColor.systemTeal.withAlphaComponent(0.3)
                    renderer.strokeColor = UIColor.systemTeal.withAlphaComponent(0.8)
                    renderer.lineWidth = 2.0
                    print("🌿 Created polygon renderer with \(polygon.pointCount) points")
                }
                
                return renderer
            }
            
            // Fallback for other overlay types
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
