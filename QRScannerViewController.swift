//
//  QRScannerViewController.swift
//  QRScanner
//
//  Created by Diego Murillo on 10/22/24.
//

import SwiftUI
import AVFoundation

struct QRScannerViewController: UIViewControllerRepresentable {
    var didFindCode: (String) -> Void  // Closure to handle the scanned QR code
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerViewController
        var lastZoomFactor: CGFloat = 1.0  // Track the last zoom factor

        init(parent: QRScannerViewController) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }

                // When QR code is scanned, stop the session and pass the result
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.didFindCode(stringValue)  // Pass the scanned code to ContentView
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        // Add pinch-to-zoom gesture
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        viewController.view.addGestureRecognizer(pinchGestureRecognizer)

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update here
    }
}

extension QRScannerViewController.Coordinator {
    // Handle pinch gesture for zoom
    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if pinch.state == .changed {
            let newZoomFactor = min(max(1.0, lastZoomFactor * pinch.scale), device.activeFormat.videoMaxZoomFactor)

            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoomFactor
                device.unlockForConfiguration()
            } catch {
                print("Failed to adjust zoom: \(error)")
            }
        }

        if pinch.state == .ended {
            lastZoomFactor = device.videoZoomFactor  // Store the last zoom factor
        }
    }
}
