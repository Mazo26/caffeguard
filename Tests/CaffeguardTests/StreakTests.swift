import Testing
@testable import Caffeguard

struct StreakTests {
    @Test func threeFacingFramesInARowConfirmAnIntrusion() {
        var streak = Streak(needed: 3)
        #expect([true, true, true].map { streak.record($0) } == [false, false, true])
    }

    @Test func aFrameWithoutAFaceResetsTheStreak() {
        var streak = Streak(needed: 3)
        #expect([true, true, false, true, true].map { streak.record($0) } == [false, false, false, false, false])
    }
}
