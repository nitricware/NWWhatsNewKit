//
//  NWWhatsNewDecodingTests.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import Foundation
import Testing
import NWWhatsNewKit

@Suite("Decoding")
struct NWWhatsNewDecodingTests {
    private func symbol(_ json: String) throws -> NWWhatsNewSymbol {
        try JSONDecoder().decode(NWWhatsNewSymbol.self, from: Data(json.utf8))
    }

    private func colorName(_ color: NWWhatsNewColor) -> String? {
        if case .named(let name, _) = color { return name }
        return nil
    }

    // MARK: - Symbol

    @Test("Symbol as plain string uses defaults")
    func symbolString() throws {
        let sut = try symbol(#""icloud""#)
        #expect(sut.name == "icloud")
        #expect(sut.rendering == .monochrome)
        #expect(sut.colors.isEmpty)
        #expect(sut.gradient == false)
        #expect(sut.variableValue == nil)
        #expect(sut.variableMode == .color)
        #expect(sut.effect == nil)
    }

    @Test("Symbol as object decodes all keys")
    func symbolObject() throws {
        let sut = try symbol("""
        {
          "name": "wifi",
          "rendering": "palette",
          "colors": ["pink", "#FFFFFF", "BrandBlue"],
          "gradient": true,
          "variableValue": 0.6,
          "variableMode": "draw",
          "effect": "bounce"
        }
        """)
        #expect(sut.name == "wifi")
        #expect(sut.rendering == .palette)
        #expect(sut.colors.map(colorName) == ["pink", "#FFFFFF", "BrandBlue"])
        #expect(sut.gradient)
        #expect(sut.variableValue == 0.6)
        #expect(sut.variableMode == .draw)
        #expect(sut.effect == .bounce)
    }

    @Test("Symbol object with only name uses defaults")
    func symbolObjectDefaults() throws {
        let sut = try symbol(#"{ "name": "map" }"#)
        #expect(sut.name == "map")
        #expect(sut.rendering == .monochrome)
        #expect(sut.colors.isEmpty)
        #expect(sut.gradient == false)
        #expect(sut.variableMode == .color)
        #expect(sut.effect == nil)
    }

    @Test("More than three colors are truncated")
    func colorsTruncated() throws {
        let sut = try symbol(#"{ "name": "map", "colors": ["red", "green", "blue", "pink"] }"#)
        #expect(sut.colors.map(colorName) == ["red", "green", "blue"])
    }

    @Test("All documented effects decode", arguments: ["bounce", "pulse", "wiggle", "breathe", "rotate", "variableColor", "drawOn"])
    func effectsDecode(effect: String) throws {
        let sut = try symbol(#"{ "name": "map", "effect": "\#(effect)" }"#)
        #expect(sut.effect?.rawValue == effect)
    }

    @Test("All documented rendering modes decode", arguments: ["monochrome", "hierarchical", "palette", "multicolor"])
    func renderingModesDecode(rendering: String) throws {
        let sut = try symbol(#"{ "name": "map", "rendering": "\#(rendering)" }"#)
        #expect(sut.rendering.rawValue == rendering)
    }

    @Test("Unknown enum values fall back to defaults")
    func unknownValuesFallBack() throws {
        let sut = try symbol(#"{ "name": "map", "rendering": "neon", "variableMode": "fill", "effect": "explode" }"#)
        #expect(sut.rendering == .monochrome)
        #expect(sut.variableMode == .color)
        #expect(sut.effect == nil)
    }

    @Test("Missing name throws")
    func missingNameThrows() {
        #expect(throws: DecodingError.self) {
            try symbol(#"{ "rendering": "palette" }"#)
        }
    }

    // MARK: - Release notes

    @Test("Release notes decode items in order")
    func releaseNotes() throws {
        let json = """
        {
          "items": [
            { "symbol": "icloud", "title": "a.title", "description": "a.description" },
            { "symbol": { "name": "map" }, "title": "b.title", "description": "b.description" }
          ]
        }
        """
        let sut = try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data(json.utf8))
        #expect(sut.items.map(\.title) == ["a.title", "b.title"])
        #expect(sut.items.map(\.description) == ["a.description", "b.description"])
        #expect(sut.items.map(\.symbol.name) == ["icloud", "map"])
        #expect(sut.items.map(\.id) == ["a.title", "b.title"])
    }

    @Test("Missing description decodes as nil")
    func missingDescription() throws {
        let json = #"{ "items": [ { "symbol": "icloud", "title": "t" } ] }"#
        let sut = try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data(json.utf8))
        #expect(sut.items.first?.description == nil)
    }

    @Test("Image and image description decode")
    func imageFields() throws {
        let json = #"{ "items": [ { "symbol": "map", "title": "t", "image": "WhatsNewMap", "imageDescription": "a11y" } ] }"#
        let item = try #require(try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data(json.utf8)).items.first)
        #expect(item.image == "WhatsNewMap")
        #expect(item.imageDescription == "a11y")
    }

    @Test("Missing image fields decode as nil")
    func missingImageFields() throws {
        let json = #"{ "items": [ { "symbol": "map", "title": "t" } ] }"#
        let item = try #require(try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data(json.utf8)).items.first)
        #expect(item.image == nil)
        #expect(item.imageDescription == nil)
    }

    @Test("Item init defaults optional fields to nil")
    func itemInitDefaults() {
        let item = NWWhatsNewItem(symbol: .init(name: "map"), title: "t")
        #expect(item.description == nil)
        #expect(item.image == nil)
        #expect(item.imageDescription == nil)
        #expect(item.id == "t")
    }

    @Test("Symbol init truncates colors to three")
    func symbolInitTruncatesColors() {
        let sut = NWWhatsNewSymbol(name: "map", colors: [.named("red"), .named("green"), .named("blue"), .named("pink")])
        #expect(sut.colors.count == 3)
    }

    @Test("Color object decodes name and opacity")
    func colorObjectDecodes() throws {
        let color = try JSONDecoder().decode(NWWhatsNewColor.self, from: Data(#"{ "color": "pink", "opacity": 0.4 }"#.utf8))
        guard case .named(let name, let opacity) = color else {
            Issue.record("Expected .named")
            return
        }
        #expect(name == "pink")
        #expect(opacity == 0.4)
    }

    @Test("Color object without opacity is fully opaque")
    func colorObjectDefaultOpacity() throws {
        let color = try JSONDecoder().decode(NWWhatsNewColor.self, from: Data(#"{ "color": "pink" }"#.utf8))
        guard case .named(_, let opacity) = color else {
            Issue.record("Expected .named")
            return
        }
        #expect(opacity == 1)
    }

    @Test("Color string is fully opaque")
    func colorStringDefaultOpacity() throws {
        let color = try JSONDecoder().decode(NWWhatsNewColor.self, from: Data(#""pink""#.utf8))
        guard case .named(_, let opacity) = color else {
            Issue.record("Expected .named")
            return
        }
        #expect(opacity == 1)
    }

    @Test("Opacity is clamped to 0...1", arguments: [(-0.5, 0.0), (1.5, 1.0), (0.3, 0.3)])
    func opacityClamped(input: Double, expected: Double) throws {
        let json = #"{ "color": "pink", "opacity": \#(input) }"#
        let color = try JSONDecoder().decode(NWWhatsNewColor.self, from: Data(json.utf8))
        guard case .named(_, let opacity) = color else {
            Issue.record("Expected .named")
            return
        }
        #expect(opacity == expected)
    }

    @Test("Color object without color throws")
    func colorObjectWithoutColorThrows() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(NWWhatsNewColor.self, from: Data(#"{ "opacity": 0.5 }"#.utf8))
        }
    }

    @Test("Palette with three colors and opacity decodes")
    func paletteWithOpacity() throws {
        let sut = try symbol("""
        {
          "name": "thermometer.medium",
          "rendering": "palette",
          "colors": ["gray", { "color": "purple", "opacity": 0.6 }, "red"]
        }
        """)
        #expect(sut.colors.map(colorName) == ["gray", "purple", "red"])
    }

    @Test("Color decodes as named")
    func colorDecodesNamed() throws {
        let color = try JSONDecoder().decode(NWWhatsNewColor.self, from: Data(#""BrandBlue""#.utf8))
        #expect(colorName(color) == "BrandBlue")
    }

    @Test("Item without symbol throws")
    func itemWithoutSymbolThrows() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(NWWhatsNewItem.self, from: Data(#"{ "title": "t" }"#.utf8))
        }
    }

    @Test("Item without title throws")
    func itemWithoutTitleThrows() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(NWWhatsNewItem.self, from: Data(#"{ "symbol": "map" }"#.utf8))
        }
    }

    @Test("Release notes without items key throw")
    func releaseNotesWithoutItemsThrow() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data("{}".utf8))
        }
    }

    @Test("Unquoted keys are rejected")
    func unquotedKeysRejected() {
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data(#"{ items: [] }"#.utf8))
        }
    }

    @Test("load(from:) reads a file")
    func loadFromFile() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data(#"{ "items": [ { "symbol": "icloud", "title": "t", "description": "d" } ] }"#.utf8).write(to: url)

        let sut = try NWWhatsNewReleaseNotes.load(from: url)
        #expect(sut.items.count == 1)
    }

    @Test("load(from:) throws on broken JSON")
    func loadBrokenJSON() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("{ not json".utf8).write(to: url)

        #expect(throws: (any Error).self) {
            try NWWhatsNewReleaseNotes.load(from: url)
        }
    }

    @Test("load(from:) throws on missing file")
    func loadMissingFile() {
        let url = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
        #expect(throws: (any Error).self) {
            try NWWhatsNewReleaseNotes.load(from: url)
        }
    }
}
