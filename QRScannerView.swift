// Diego contributed to this file
// This file handles the QR code scanner scene, which then transitions to the camera once start scanning is pressed
// This follows the same set up as the other view.swift files, so used those for reference

import SwiftUI

struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var currentScreen: Screen // keeps track of the current scene
    @Binding var previousScreen: Screen // keeps track of the previous

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // title and explanation
            Text("QR Code Scanner")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 10)
            
            Text("""
                Use the QR Code Scanner to scan URLs or other information encoded in QR codes. 
                Once scanned, results will display as follows:
                - Green: Safe URL
                - Yellow: Potentially risky
                - Red: Malicious or harmful
                """)
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(.gray)
            
            Spacer()
            
            // Start Scanning button
            Button(action: {
                    previousScreen = .qrScanner  // Set the previousScreen to QRScannerView
                    currentScreen = .scanning // transitions to camera scene for scanning
                }) {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title)
                    Text("Start Scanning")
                        .font(.title3)
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Back Button
            Button(action: {
                currentScreen = .home  // In the QR code scanner view, the back button directs to the main menu
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .padding()
                .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
