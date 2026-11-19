//
//  NWWhatsNewColor.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public enum NWWhatsNewColor: Sendable, Decodable {
    case color(Color)
    case named(String, opacity: Double = 1)

    private enum CodingKeys: String, CodingKey {
        case color, opacity
    }

    public init(from decoder: Decoder) throws {
        if let name = try? decoder.singleValueContainer().decode(String.self) {
            self = .named(name)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1
        self = .named(
            try container.decode(String.self, forKey: .color),
            opacity: min(max(opacity, 0), 1)
        )
    }

    func resolve(in bundle: Bundle) -> Color {
        switch self {
        case .color(let color):
            color
        case .named(let name, let opacity):
            opacity < 1 ? Self.resolve(name, in: bundle).opacity(opacity) : Self.resolve(name, in: bundle)
        }
    }

    private static func resolve(_ name: String, in bundle: Bundle) -> Color {
        hex(name) ?? system(name) ?? asset(name, in: bundle) ?? .accentColor
    }

    static func hex(_ name: String) -> Color? {
        guard name.hasPrefix("#"), name.count == 7 || name.count == 9,
              let value = UInt64(name.dropFirst(), radix: 16) else { return nil }

        let hasAlpha = name.count == 9
        let rgb = hasAlpha ? value >> 8 : value
        let alpha = hasAlpha ? Double(value & 0xFF) / 255 : 1

        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: alpha
        )
    }

    static func system(_ name: String) -> Color? {
        switch name.lowercased() {
        case "red": .red
        case "orange": .orange
        case "yellow": .yellow
        case "green": .green
        case "mint": .mint
        case "teal": .teal
        case "cyan": .cyan
        case "blue": .blue
        case "indigo": .indigo
        case "purple": .purple
        case "pink": .pink
        case "brown": .brown
        case "gray": .gray
        case "white": .white
        case "black": .black
        case "primary": .primary
        case "secondary": .secondary
        case "accent": .accentColor
        default: nil
        }
    }

    static func asset(_ name: String, in bundle: Bundle) -> Color? {
        #if canImport(UIKit)
        guard UIColor(named: name, in: bundle, compatibleWith: nil) != nil else { return nil }
        #elseif canImport(AppKit)
        guard NSColor(named: name, bundle: bundle) != nil else { return nil }
        #endif
        return Color(name, bundle: bundle)
    }
}
