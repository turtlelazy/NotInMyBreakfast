//
//  BarcodeScannerView.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/23/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        print("[BarcodeScannerView] makeUIView called")
        
        // Check camera authorization status
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("[BarcodeScannerView] Camera authorization status: \(authStatus.rawValue)")
        
        if authStatus == .notDetermined {
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print("[BarcodeScannerView] Camera access granted: \(granted)")
            }
        } else if authStatus != .authorized {
            print("[BarcodeScannerView] Camera access denied or restricted")
            return view
        }

        let session = AVCaptureSession()
        context.coordinator.session = session

        guard let device = AVCaptureDevice.default(for: .video) else {
            print("[BarcodeScannerView] Failed to get AVCaptureDevice.")
            return view
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("[BarcodeScannerView] Failed to create AVCaptureDeviceInput.")
            return view
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)

        output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        // Food products typically use EAN-13, EAN-8, UPC-A, or UPC-E barcodes
        output.metadataObjectTypes = [.ean13, .ean8, .upce]
        
        print("[BarcodeScannerView] Metadata object types set for food barcodes: \(output.metadataObjectTypes)")

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = UIScreen.main.bounds
        view.layer.addSublayer(preview)

        print("[BarcodeScannerView] AVCaptureSession and preview layer set up.")
        // Do not start the session here; control start/stop from `updateUIView` using `isScanning` binding
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let session = context.coordinator.session else {
            print("[BarcodeScannerView] No session available in updateUIView.")
            return
        }
        
        // AVCaptureSession operations should be on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isScanning {
                if !session.isRunning {
                    print("[BarcodeScannerView] Starting session.")
                    session.startRunning()
                }
            } else {
                if session.isRunning {
                    print("[BarcodeScannerView] Stopping session.")
                    session.stopRunning()
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        var session: AVCaptureSession?

        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            print("[BarcodeScannerView] metadataOutput called with \(metadataObjects.count) objects")
            
            if metadataObjects.isEmpty {
                print("[BarcodeScannerView] No metadata objects detected.")
                return
            }
            guard let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                print("[BarcodeScannerView] First object is not a machine readable code object. Type: \(type(of: metadataObjects.first))")
                return
            }
            
            // Log the barcode type (EAN-13, EAN-8, UPC-E, etc.)
            print("[BarcodeScannerView] Barcode type detected: \(first.type.rawValue)")
            
            guard let value = first.stringValue else {
                print("[BarcodeScannerView] No string value in detected code object.")
                return
            }

            print("[BarcodeScannerView] Food barcode scanned: \(value)")
            
            // Update parent binding on main thread
            DispatchQueue.main.async {
                self.parent.scannedCode = value
                self.parent.isScanning = false
            }

            // Stop scanning once we get one code (on background thread)
            print("[BarcodeScannerView] Stopping session after successful scan.")
            DispatchQueue.global(qos: .userInitiated).async {
                self.session?.stopRunning()
            }
        }
    }
}
