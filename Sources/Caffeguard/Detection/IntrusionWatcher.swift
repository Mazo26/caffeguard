import AVFoundation
import CoreImage

/// Samples a camera a couple of times per second and reports every intrusion that
/// `IntrusionRule` confirms, as an unannotated JPEG of the confirming frame.
///
/// `@unchecked Sendable`: every mutable property is only touched on `queue`.
nonisolated final class IntrusionWatcher: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    struct CameraUnavailable: Error {}

    static let samplesPerSecond = 2.0

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "Caffeguard.camera")
    private let context = CIContext()
    private let onIntrusion: @Sendable (Data) -> Void
    // 3 frames is 1.5 seconds of facing the camera; 60 frames is 30 seconds with nobody there.
    private var rule = IntrusionRule(framesToConfirm: 3, framesToClear: 60)
    private var lastSample = CMTime.invalid

    init(device: AVCaptureDevice, onIntrusion: @escaping @Sendable (Data) -> Void) throws {
        self.onIntrusion = onIntrusion
        super.init()
        let input = try AVCaptureDeviceInput(device: device)
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: queue)
        guard session.canAddInput(input), session.canAddOutput(output) else { throw CameraUnavailable() }
        session.addInput(input)
        session.addOutput(output)
    }

    func start() { queue.async { self.session.startRunning() } }
    func stop() { queue.async { self.session.stopRunning() } }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let time = sampleBuffer.presentationTimeStamp
        guard !lastSample.isValid || (time - lastSample).seconds >= 1 / Self.samplesPerSecond,
              let frame = sampleBuffer.imageBuffer
        else { return }
        lastSample = time

        guard rule.record(FaceDetector.someoneIsFacing(frame)) else { return }
        let image = CIImage(cvPixelBuffer: frame)
        let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        if let jpeg = context.jpegRepresentation(of: image, colorSpace: colorSpace) {
            onIntrusion(jpeg)
        }
    }
}
