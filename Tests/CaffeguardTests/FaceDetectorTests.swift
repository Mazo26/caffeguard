import Testing
@testable import Caffeguard

struct FaceDetectorTests {
    @Test(arguments: [0.0, 0.3, -0.3])
    func aFaceTurnedLessThan25DegreesIsFacingTheCamera(yaw: Double) {
        #expect(FaceDetector.isFacing(yaw: yaw))
    }

    @Test(arguments: [0.8, -0.8, nil] as [Double?])
    func aFaceInProfileOrWithUnknownYawIsNotFacingTheCamera(yaw: Double?) {
        #expect(!FaceDetector.isFacing(yaw: yaw))
    }
}
