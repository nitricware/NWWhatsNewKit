//
//  NWWhatsNewSymbol.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public struct NWWhatsNewSymbol: Sendable {
    public enum Rendering: String, Sendable {
        case monochrome, hierarchical, palette, multicolor
    }

    public enum VariableMode: String, Sendable {
        case color, draw
    }

    public enum Effect: String, Sendable {
        case bounce, pulse, wiggle, breathe, rotate, variableColor, drawOn
    }

    public let name: String
    public let rendering: Rendering
    public let colors: [NWWhatsNewColor]
    public let gradient: Bool
    public let variableValue: Double?
    public let variableMode: VariableMode
    public let effect: Effect?

    public init(
        name: String,
        rendering: Rendering = .monochrome,
        colors: [NWWhatsNewColor] = [],
        gradient: Bool = false,
        variableValue: Double? = nil,
        variableMode: VariableMode = .color,
        effect: Effect? = nil
    ) {
        self.name = name
        self.rendering = rendering
        self.colors = Array(colors.prefix(3))
        self.gradient = gradient
        self.variableValue = variableValue
        self.variableMode = variableMode
        self.effect = effect
    }
}

extension NWWhatsNewSymbol: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name, rendering, colors, gradient, variableValue, variableMode, effect
    }

    public init(from decoder: Decoder) throws {
        if let name = try? decoder.singleValueContainer().decode(String.self) {
            self.init(name: name)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            rendering: try Self.lenient(Rendering.self, container, .rendering) ?? .monochrome,
            colors: try container.decodeIfPresent([NWWhatsNewColor].self, forKey: .colors) ?? [],
            gradient: try container.decodeIfPresent(Bool.self, forKey: .gradient) ?? false,
            variableValue: try container.decodeIfPresent(Double.self, forKey: .variableValue),
            variableMode: try Self.lenient(VariableMode.self, container, .variableMode) ?? .color,
            effect: try Self.lenient(Effect.self, container, .effect)
        )
    }

    private static func lenient<T: RawRepresentable>(
        _ type: T.Type,
        _ container: KeyedDecodingContainer<CodingKeys>,
        _ key: CodingKeys
    ) throws -> T? where T.RawValue == String {
        guard let raw = try container.decodeIfPresent(String.self, forKey: key) else { return nil }
        return T(rawValue: raw)
    }
}
