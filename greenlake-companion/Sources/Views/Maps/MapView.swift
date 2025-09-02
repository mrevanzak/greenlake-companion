//
//  MapsView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import MapKit
import SwiftUI
import SwiftUIX

/// Main Maps view replicating Apple Maps interface and functionality
struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var plantManager = PlantManager.shared
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingPlantDetails = false
    @State private var selectedItem: String = "Mode"
    @State private var showMenu = false
        
    private let items = ["Pencatatan", "Label", "Label 2"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map background
            mapContent
            
            // Top controls overlay
            logoutButton
            
            // Loading indicator overlay
            loadingIndicator
            
            // Bottom rectangle overlay
                      topControl
        }
        .environmentObject(locationManager)
        .onAppear {
            setupInitialState()
            Task {
                await plantManager.loadPlants()
            }
        }
        .adaptiveSheet(
            isPresented: .constant(true),
            configuration: AdaptiveSheetConfiguration(detents: [.height(100), .large])
        ) {
            BottomSheetContent()
        }
        .adaptiveSheet(
            isPresented: $showingPlantDetails,
            configuration: AdaptiveSheetConfiguration(detents: [.large])
        ) {
            if let selectedPlant = plantManager.selectedPlant {
                PlantDetailView(
                    plant: selectedPlant,
                    mode: .update,
                    onDismiss: {
                        showingPlantDetails = false
                        plantManager.selectPlant(nil)
                    }
                )
            }
        }
        .adaptiveSheet(
            isPresented: $plantManager.isCreatingPlant,
            configuration: AdaptiveSheetConfiguration(detents: [.large])
        ) {
            if let tempPlant = plantManager.temporaryPlant {
                PlantDetailView(
                    plant: tempPlant,
                    mode: .create,
                    onDismiss: { plantManager.discardTemporaryPlant() }
                )
            }
        }
        .onChange(of: plantManager.selectedPlant) { oldValue, newValue in
            showingPlantDetails = newValue != nil
        }
        .alert("Error", isPresented: .constant(plantManager.error != nil)) {
            Button("OK") { plantManager.clearError() }
        } message: {
            if let error = plantManager.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    // MARK: - View Components
    
    private var mapContent: some View {
        MapViewRepresentable(
            locationManager: locationManager,
            plantManager: plantManager
        )
        .ignoresSafeArea()
    }
    
    private var logoutButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    authManager.logout()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
            }
            Spacer()
        }
    }
    
    private var loadingIndicator: some View {
        Group {
            if plantManager.isLoading {
                VStack {
                    ProgressView("Loading...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 100)
            }
        }
    }
    
    private var topControl: some View {
        VStack {
            // Top-most button positioned at the top of the screen
            Button(action: {
                withAnimation {
                    showMenu.toggle()
                }
            }) {
                HStack {
                    Text("Mode")
                        .font(.system(size: 18, weight: .medium)) // SF Pro Medium 20/24
                        .foregroundColor(.black.opacity(0.7))
                    HStack{
                        Text(selectedItem)
                            .font(.system(size: 18, weight: .medium)) // SF Pro Medium 20/24
                            .foregroundColor(.black.opacity(1))
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 34)
                    .background(Color(.systemBackground).opacity(1))
                    .cornerRadius(17)  // Rounded corners for button
//                    .shadow(radius: 5)  // Soft shadow effect
                }
                .padding(.top, 3)
                .padding(.leading)
                .padding(.trailing, 3)
                .padding(.bottom, 3)
                .frame(height: 40)
                .background(Color(.systemGray5).opacity(1))
                .cornerRadius(20)  // Rounded corners for button
//                .shadow(radius: 5)  // Soft shadow effect
            }
            .frame(maxWidth: .infinity)  // Ensures button spans full width
            .zIndex(1) // Ensures button is on top

            // Dropdown Menu
            if showMenu {
                VStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Button(action: {
                            selectedItem = item
                            showMenu.toggle()
                        }) {
                            Text(item)
                                .font(.system(size: 20, weight: .medium)) // SF Pro Medium 20/24
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .frame(height: 40)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .transition(.move(edge: .top))  // Smooth transition for dropdown
                .padding(.top, 8)
                .zIndex(2) // Ensures dropdown is above other content
            }
            
            Spacer() // Pushes everything to the top of the screen
        }
        .padding(.top, 29) // Space for dropdown
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity) // Ensure the container takes up the full width
    }


    // MARK: - Helper Methods
    
    private func setupInitialState() {
        // Request location permission and start tracking
        locationManager.requestLocation()
    }
}

//// MARK: - Preview
//
//#Preview {
//  MapView()
//    .environmentObject(AuthManager.shared)
//}
