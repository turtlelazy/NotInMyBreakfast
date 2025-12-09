//
//  BarcodeDetector.swift
//  NotInMyBreakfast
//
//  Created by Ishraq Mahid on 11/23/25.
//

import Foundation
import UIKit
import Vision

class BarcodeDetector {
    static func detectBarcode(from image: UIImage, completion: @escaping (String?) -> Void) {
        print("BarcodeDetector: Starting barcode detection for image...")
        print("BarcodeDetector: Image size: \(image.size), scale: \(image.scale), orientation: \(image.imageOrientation.rawValue)")
        
        // Ensure we have a CGImage; convert from CIImage if needed
        var workingCGImage: CGImage?
        if let cg = image.cgImage {
            workingCGImage = cg
        } else if let ci = image.ciImage {
            let ctx = CIContext(options: nil)
            workingCGImage = ctx.createCGImage(ci, from: ci.extent)
        }

        guard let cgImage = workingCGImage else {
            print("BarcodeDetector: failed to get CGImage from UIImage")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        // Map UIImage orientation to CGImagePropertyOrientation for Vision
        func cgOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
            switch uiOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
            @unknown default: return .up
            }
        }
        // Figure out if this object supports barcode requests
        // if not, focus on other stuff with manual input
        // swiftdata implementation
        
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("BarcodeDetector: VNDetectBarcodesRequest error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            if let results = request.results as? [VNBarcodeObservation], !results.isEmpty {
                print("BarcodeDetector: Found \(results.count) barcode(s)")
                
                for (index, obs) in results.enumerated() {
                    print("BarcodeDetector: Barcode \(index): type=\(obs.symbology.rawValue), confidence=\(obs.confidence), bounds=\(obs.boundingBox)")
                    if let payload = obs.payloadStringValue {
                        print("BarcodeDetector: Successfully detected barcode: \(payload)")
                        DispatchQueue.main.async { completion(payload) }
                        return
                    } else {
                        print("BarcodeDetector: No payload string for barcode \(index)")
                    }
                }
                
                // No valid payload found in any observation
                print("BarcodeDetector: No valid payload string in any detected barcode")
                DispatchQueue.main.async { completion(nil) }
            } else {
                print("BarcodeDetector: no barcode observations found - image may be unclear, barcode too small, or unsupported format")
                DispatchQueue.main.async { completion(nil) }
            }
        }
        
        // Leave symbologies unspecified to allow Vision to detect all supported types
        // This is more flexible than restricting to specific types
        print("BarcodeDetector: Using default symbologies (all supported types)")

        let orientation = cgOrientation(from: image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("BarcodeDetector: handler.perform error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
