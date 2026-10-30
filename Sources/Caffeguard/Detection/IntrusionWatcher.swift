import AVFoundation
import CoreImage

/// Samples a camera a couple of times per second and reports the first frame in which
/// someone has faced it for `framesNeeded` samples in a row, as an unannotated JPEG.
///
/// `@unchecked Sendable`: every mutable property is only touched on `queue`.
nonisolated final class IntrusionWatcher: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    struct CameraUnavailable: Error {}

    static let samplesPerSecond = 2.0
    static let framesNeeded = 3

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "Caffeguard.camera")
    private let context = CIContext()
    private let onIntrusion: @Sendable (Data) -> Void
    private var streak = Streak(needed: framesNeeded)
    private var lastSample = CMTime.invalid
    private var reported = false

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
        guard !reported,
              !lastSample.isValid || (time - lastSample).seconds >= 1 / Self.samplesPerSecond,
              let frame = sampleBuffer.imageBuffer
        else { return }
        lastSample = time

        guard streak.record(FaceDetector.someoneIsFacing(frame)) else { return }
        reported = true
        let image = CIImage(cvPixelBuffer: frame)
        let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        if let jpeg = context.jpegRepresentation(of: image, colorSpace: colorSpace) {
            onIntrusion(jpeg)
        }
    }
}
