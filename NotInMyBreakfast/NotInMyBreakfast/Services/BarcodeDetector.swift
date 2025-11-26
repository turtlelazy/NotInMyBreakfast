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

        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("BarcodeDetector: VNDetectBarcodesRequest error: \(error.localizedDescription)")
            }

            if let results = request.results as? [VNBarcodeObservation], !results.isEmpty {
                // Prefer payloadStringValue. Some barcode types may not provide a payloadStringValue;
                // in that case, attempt to extract a string from the barcodeDescriptor if present.
                if let obs = results.first {
                    if let payload = obs.payloadStringValue {
                        DispatchQueue.main.async { completion(payload) }
                        return
                    }

                    // No payload string available for this observation
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
            } else {
                print("BarcodeDetector: no barcode observations found")
                DispatchQueue.main.async { completion(nil) }
            }
        }

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
