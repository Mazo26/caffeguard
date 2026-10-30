import Testing
@testable import Caffeguard

struct IntrusionRuleTests {
    private func run(_ frames: [Bool]) -> [Int] {
        var rule = IntrusionRule(framesToConfirm: 3, framesToClear: 4)
        return frames.indices.filter { rule.record(frames[$0]) }
    }

    @Test func threeFacingFramesInARowConfirmAnIntrusion() {
        #expect(run([true, true, true]) == [2])
    }

    @Test func aFrameWithoutAFaceResetsTheStreak() {
        #expect(run([true, true, false, true, true]) == [])
    }

    @Test func onePersonStayingInViewIsReportedOnce() {
        #expect(run(Array(repeating: true, count: 20)) == [2])
    }

    @Test func aShortGlanceAwayIsStillTheSamePerson() {
        #expect(run([true, true, true, false, false, false, true, true, true]) == [2])
    }

    @Test func theNextPersonAfterTheSceneClearsIsReportedAgain() {
        let first = [true, true, true]
        let gone = [false, false, false, false]
        let second = [true, true, true]
        #expect(run(first + gone + second) == [2, 9])
    }
}
