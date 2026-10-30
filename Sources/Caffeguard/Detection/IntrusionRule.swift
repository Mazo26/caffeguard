/// Turns per-frame "is someone facing the camera" answers into intrusion events.
///
/// An intrusion is `framesToConfirm` facing frames in a row, so one false detection never
/// counts. After an intrusion, the camera must see nobody facing it for `framesToClear`
/// frames in a row before the next one can be reported: one person staring at the red
/// screen is one photo, but the next person who sits down is a new one.
nonisolated struct IntrusionRule {
    let framesToConfirm: Int
    let framesToClear: Int
    private var facing = 0
    private var empty = 0
    private var awaitingClear = false

    init(framesToConfirm: Int, framesToClear: Int) {
        self.framesToConfirm = framesToConfirm
        self.framesToClear = framesToClear
    }

    /// Records one frame and returns whether it completes a new intrusion.
    mutating func record(_ someoneIsFacing: Bool) -> Bool {
        if someoneIsFacing {
            facing += 1
            empty = 0
        } else {
            empty += 1
            facing = 0
        }
        if awaitingClear {
            if empty >= framesToClear { awaitingClear = false }
            return false
        }
        guard facing >= framesToConfirm else { return false }
        awaitingClear = true
        return true
    }
}
