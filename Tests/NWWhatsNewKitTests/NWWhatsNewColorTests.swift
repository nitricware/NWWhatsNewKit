//
//  NWWhatsNewColorTests.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI
import Testing
@testable import NWWhatsNewKit

private final class BundleToken {}
private var testBundle: Bundle { Bundle(for: BundleToken.self) }

@Suite("Color resolution")
struct NWWhatsNewColorTests {
    @Test("Hex is parsed")
    func hex() {
        #expect(NWWhatsNewColor.named("#FF0000").resolve(in: testBundle) == Color(red: 1, green: 0, blue: 0))
    }

    @Test("Hex with alpha is parsed")
    func hexWithAlpha() {
        #expect(NWWhatsNewColor.named("#FF000080").resolve(in: testBundle) == Color(red: 1, green: 0, blue: 0, opacity: 128.0 / 255))
    }

    @Test("Opacity is applied to named colors")
    func opacityApplied() {
        #expect(NWWhatsNewColor.named("pink", opacity: 0.5).resolve(in: testBundle) == Color.pink.opacity(0.5))
    }

    @Test("Invalid hex is not parsed", arguments: ["#FFF", "#GGGGGG", "FF0000", "#FF00000", "#FF0000000"])
    func invalidHex(name: String) {
        #expect(NWWhatsNewColor.hex(name) == nil)
    }

    @Test("System names resolve case-insensitively", arguments: [("pink", Color.pink), ("Cyan", .cyan), ("ACCENT", .accentColor)])
    func systemNames(name: String, expected: Color) {
        #expect(NWWhatsNewColor.named(name).resolve(in: testBundle) == expected)
    }

    @Test("Unknown name falls back to accent color")
    func unknownName() {
        #expect(NWWhatsNewColor.named("DoesNotExist").resolve(in: testBundle) == .accentColor)
    }

    @Test("Explicit color is returned unchanged")
    func explicitColor() {
        #expect(NWWhatsNewColor.color(.indigo).resolve(in: testBundle) == .indigo)
    }
}
