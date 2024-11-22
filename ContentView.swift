//
//  ContentView.swift
//  QRScanner
//
//  Created by Diego Murillo on 10/22/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var showScanner = false  // Control whether to show the scanner or home screen
    @State private var scannedCode: String?
    @State private var isScanning = true

    var body: some View {
        if showScanner {
            VStack {
                if let code = scannedCode {
                    Text("Reputation Check: \(code)")  // Display the result of URL reputation check here
                    Button("Scan Again") {
                        self.scannedCode = nil
                        self.isScanning = true
                    }
                } else {
                    if isScanning {
                        QRScannerViewController { scannedCode in
                            self.scannedCode = scannedCode
                            self.isScanning = false
                            
                            // Call your URL reputation check here
                            checkUrlReputation(scannedCode) { reputationResult in
                                // Handle the result here, e.g., updating the UI
                                self.scannedCode = reputationResult  // Update with the reputation result
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                    } else {
                        Button("Scan Again") {
                            self.scannedCode = nil
                            self.isScanning = true
                        }
                    }
                }
            }
        } else {
            VStack {
                Text("Welcome!")
                    .font(.largeTitle)
                    .padding()
                
                Text("Press this button to begin scanning a QR code")
                    .padding()
                
                Button("Begin Scanning") {
                    showScanner = true  // Transition to the scanner
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }

    func checkUrlReputation(_ url: String, completion: @escaping (String) -> Void) {
        let apiKey = ""  // Replace with your actual API key
        let apiUrl = "https://www.virustotal.com/vtapi/v2/url/report"
        let urlComponents = URLComponents(string: apiUrl)
        
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "apikey": apiKey,
            "resource": url
        ]
        
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let positives = json["positives"] as? Int,
                   let total = json["total"] as? Int {
                    let resultMessage = "Total Scans: \(total)\nFlagged as Malicious by \(positives) engines."
                    completion(resultMessage)
                } else {
                    completion("Invalid response from VirusTotal")
                }
            } catch {
                completion("Failed to parse response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
