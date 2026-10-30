/// Counts consecutive hits. An intrusion needs `needed` facing frames in a row,
/// so a single false detection never triggers the alert.
nonisolated struct Streak {
    let needed: Int
    private(set) var count = 0

    /// Records one frame and returns whether the streak is now long enough.
    mutating func record(_ hit: Bool) -> Bool {
        count = hit ? count + 1 : 0
        return count >= needed
    }
}
