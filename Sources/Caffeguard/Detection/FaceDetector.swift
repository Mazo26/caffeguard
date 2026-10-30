import CoreVideo
import Vision

/// Decides whether someone in a frame is looking at the camera.
nonisolated enum FaceDetector {
    /// Faces turned further than this from the camera (about 25°) do not count.
    static let maxYaw = 0.45

    static func isFacing(yaw: Double?) -> Bool {
        guard let yaw else { return false }
        return abs(yaw) <= maxYaw
    }

    static func someoneIsFacing(_ frame: CVPixelBuffer) -> Bool {
        let request = VNDetectFaceRectanglesRequest()
        // A frame Vision cannot read counts as empty; the next sample comes half a second later.
        try? VNImageRequestHandler(cvPixelBuffer: frame).perform([request])
        return request.results?.contains { isFacing(yaw: $0.yaw?.doubleValue) } ?? false
    }
}
