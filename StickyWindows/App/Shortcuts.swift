import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let parkFrontmostRight = Self("parkFrontmostRight", default: .init(.rightArrow, modifiers: [.control, .option, .command]))
    static let parkFrontmostLeft = Self("parkFrontmostLeft", default: .init(.leftArrow, modifiers: [.control, .option, .command]))
    static let parkFrontmostBottom = Self("parkFrontmostBottom", default: .init(.downArrow, modifiers: [.control, .option, .command]))

    static let parkShortcuts: [(name: Self, edge: Edge)] = [
        (.parkFrontmostLeft, .left), (.parkFrontmostRight, .right), (.parkFrontmostBottom, .bottom),
    ]

    static let showNextParked = Self("showNextParked", default: .init(.rightBracket, modifiers: [.control, .option, .command]))
    static let showPreviousParked = Self("showPreviousParked", default: .init(.leftBracket, modifiers: [.control, .option, .command]))
    static let tuckAllParked = Self("tuckAllParked", default: .init(.zero, modifiers: [.control, .option, .command]))
    static let toggleTabsHidden = Self("toggleTabsHidden", default: .init(.h, modifiers: [.control, .option, .command]))

    /// ⌃⌥⌘1…9: the Nth parked window, counted the way `ParkingManager.keyboardOrder` lists them.
    static let showParkedByNumber: [Self] = [
        Self("showParked1", default: .init(.one, modifiers: [.control, .option, .command])),
        Self("showParked2", default: .init(.two, modifiers: [.control, .option, .command])),
        Self("showParked3", default: .init(.three, modifiers: [.control, .option, .command])),
        Self("showParked4", default: .init(.four, modifiers: [.control, .option, .command])),
        Self("showParked5", default: .init(.five, modifiers: [.control, .option, .command])),
        Self("showParked6", default: .init(.six, modifiers: [.control, .option, .command])),
        Self("showParked7", default: .init(.seven, modifiers: [.control, .option, .command])),
        Self("showParked8", default: .init(.eight, modifiers: [.control, .option, .command])),
        Self("showParked9", default: .init(.nine, modifiers: [.control, .option, .command])),
    ]
}
