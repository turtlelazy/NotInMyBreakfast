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

        let session = AVCaptureSession()
        context.coordinator.session = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return view }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)

        output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce, .qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = UIScreen.main.bounds
        view.layer.addSublayer(preview)

        // Do not start the session here; control start/stop from `updateUIView` using `isScanning` binding
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let session = context.coordinator.session else { return }
        if isScanning {
            if !session.isRunning { session.startRunning() }
        } else {
            if session.isRunning { session.stopRunning() }
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
            guard let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = first.stringValue else { return }

            parent.scannedCode = value

            // Stop scanning once we get one code
            session?.stopRunning()
        }
    }
}
