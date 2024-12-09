// Diego wrote this file
// Handles the results and camera features of the QR scanning
// Cursor helped a lot with the camera functionality as that beyond my understanding. It also helped to get the API working smoothly.

import SwiftUI
import AVFoundation

struct QRScannerScene: View {
    @State private var scannedCode: String? // this the url that is scanned from the QR code
    @State private var reputationResult: String? // the reputation check result for the QR code
    @State private var resultColor: Color = .white // color represnting the returned reputation result, will vary between green, yellow, and red
    @State private var isScanning = true // check for if the qr code scanner is active
    @Binding var currentScreen: Screen // keeps track of the current scene
    @Binding var previousScreen: Screen // keeps track of the previous
    
    var body: some View {
            ZStack {
                // if scanning is complete and data is available after scanning, display results
                if let code = scannedCode, let reputation = reputationResult {
                    VStack(spacing: 20) {
                        // this display the scanned URL
                        Text("Scanned URL:")
                            .font(.headline)
                            .foregroundColor(.white)
                        // displays the color green, yellow, red depending on security of URL
                        Text(code)
                            .foregroundColor(resultColor) // Use the color here
                        
                        // displays the reputation check results
                        Text("Reputation Check:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(reputation)
                            .foregroundColor(resultColor)
                        
                        // buttons for visitng the URL or scanning again
                        HStack(spacing: 20) {
                            Button("Visit URL") {
                                openURL(code)
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            Button("Scan Again") {
                                resetScanner()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    // display the scanning interface when currently scanning
                } else if isScanning {
                        QRScannerViewController { scannedCode in
                            self.scannedCode = scannedCode // this stores the scanned qr code
                            self.isScanning = false
                            checkUrlReputation(scannedCode) { reputationResult, color in // this then checks the reputation of the code through VirusTotal API
                                self.reputationResult = reputationResult
                                self.resultColor = color
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
            // back button located at the top of the screen to avoid cluttering the camera scene
            VStack {
                HStack {
                    Button(action: {
                        if scannedCode != nil {
                            // if showing results, go back to start scanning screen
                            currentScreen = .qrScanner
                        } else {
                            // if in camera mode, go back to previous screen
                            currentScreen = previousScreen
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                    Spacer()
                }
                .padding(.top, 50)
                Spacer()
            }
            .zIndex(1)
        }
    }

    // reset the scanning process
    func resetScanner() {
        scannedCode = nil
        reputationResult = nil
        resultColor = .white
        isScanning = true
    }

    // function to check URL reputation
        func checkUrlReputation(_ url: String, completion: @escaping (String, Color) -> Void) {
            let apiKey = "dbb29c36181bd3af6c5a5a5672df88126414919fe041447d54e75b5e9cb557e1" // VirusTotal API key
            let apiUrl = "https://www.virustotal.com/vtapi/v2/url/report" // VirusTotal API endpoint
            let urlComponents = URLComponents(string: apiUrl)
            
            var request = URLRequest(url: (urlComponents?.url)!)
            request.httpMethod = "POST" // HTTP post request
            
            // parameters for the API request
            let parameters: [String: String] = [
                "apikey": apiKey,
                "resource": url
            ]
            
            // encode parameters as URL-encoded form data
            request.httpBody = parameters
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
                .data(using: .utf8)
            
            // execute the API request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion("Error: \(error?.localizedDescription ?? "Unknown error")", .red)
                    return
                }
                
                do {
                    // this parses the JSON response
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let positives = json["positives"] as? Int,
                       let total = json["total"] as? Int {
                        let resultMessage = "Total Scans: \(total)\nFlagged as Malicious by \(positives) engines."
                        
                        // determine color based on number of positive detections
                        let color: Color
                        if positives == 0 {
                            color = .green  // safe
                        } else if positives <= 2 {
                            color = .yellow // potentially risky
                        } else {
                            color = .red // malicious
                        }
                        
                        completion(resultMessage, color)
                    } else {
                        completion("Invalid response from VirusTotal", .red)
                    }
                } catch {
                    completion("Failed to parse response: \(error.localizedDescription)", .red)
                }
            }
            
            task.resume()
        }
    

    // function to open the URL
    func openURL(_ url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}

struct QRScannerViewController: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // nothing added here
    }
    
    var didFindCode: (String) -> Void  // closure to handle the scanned QR code
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerViewController
        var lastZoomFactor: CGFloat = 1.0  // track the last zoom factor
        
        init(parent: QRScannerViewController) {
            self.parent = parent
        }
        
        // this is called whenever a QR code is detected in camera
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                // ensure the detected metadata is a readable QR code
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                // then extract the string value of the QR code
                guard let stringValue = readableObject.stringValue else { return }
                
                // vibrate device to provide feedback upon successful scanning
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.didFindCode(stringValue)  // Pass the scanned code to ContentView
            }
        }
    }
    
    // creates a coordinator object to manage interactions between the SwiftUI view and the UIKit components
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    // this function creates and returns a UIViewController to manage the QR code scanning interface
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController() // the base view controller for the camera preview
        
        let captureSession = AVCaptureSession() // initializes a new capture session for handling the camera input
        
        // retrieve the default video capture device (camera)
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput
        
        do {
            // attempt to create an input object from the capture device
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            // if input creation fails, return the empty view controller.
            return viewController
        }
        
        // add the video input to the capture session if possible
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            // else return if input could not be added
            return viewController
        }
        
        // create and configure a metadata output object for QR code detection
        let metadataOutput = AVCaptureMetadataOutput()
        
        // add the metadata output to the capture session if possible
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            // set the coordinator as the delegate to handle detected metadata objects
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            // configure the metadata output to detect QR codes
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            // if output cannot be added, return
            return viewController
        }
        
        // create a preview layer to display the camera feed
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // make it cover the entire view
        previewLayer.frame = viewController.view.layer.bounds
        // adjust the video display to fill the screen
        previewLayer.videoGravity = .resizeAspectFill
        // add the preview layer to the view
        viewController.view.layer.addSublayer(previewLayer)
        
        // start running the capture session to begin displaying the camera feed
        captureSession.startRunning()
        
        // add a pinch-to-zoom gesture recognizer to the view
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        viewController.view.addGestureRecognizer(pinchGestureRecognizer)
        
        return viewController
    }
}

extension QRScannerViewController.Coordinator {
    // handle pinch gesture for zoom
    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        // retrieve the default video capture device (camera)
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        // check if the gesture state is in progress (user is pinching)
        if pinch.state == .changed {
            // calculate the new zoom factor based on the gesture scale, clamped to valid zoom levels
            let newZoomFactor = min(max(1.0, lastZoomFactor * pinch.scale), device.activeFormat.videoMaxZoomFactor)

            do {
                // Lock the device configuration to safely update the zoom factor
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoomFactor // Apply the calculated zoom factor
                device.unlockForConfiguration() // unlock configuration after the change
            } catch {
                print("Failed to adjust zoom: \(error)")
            }
        }

        // if the gesture ends, store the current zoom factor for reference in future gestures
        if pinch.state == .ended {
            lastZoomFactor = device.videoZoomFactor  // Store the last zoom factor
        }
    }
}
