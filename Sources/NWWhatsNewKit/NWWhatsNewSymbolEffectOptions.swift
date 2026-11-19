//
//  NWWhatsNewSymbolEffectOptions.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 19.11.26.
//

import Foundation

extension NWWhatsNewSymbol {
    public struct EffectOptions: Sendable, Equatable {
        public enum Scope: String, Sendable {
            case byLayer, wholeSymbol, individually
        }

        public enum Direction: String, Sendable {
            case up, down, left, right, forward, backward, clockwise, counterClockwise
        }

        public enum BreatheStyle: String, Sendable {
            case pulse, plain
        }

        public enum VariableColorFill: String, Sendable {
            case iterative, cumulative
        }

        public enum Repetition: Sendable, Equatable {
            case once
            case count(Int)
            case continuous
            case periodic(delay: Double)
        }

        public let speed: Double
        public let repetition: Repetition
        public let scope: Scope?
        public let direction: Direction?
        public let breatheStyle: BreatheStyle?
        public let variableColorFill: VariableColorFill?
        public let reversing: Bool?

        public init(
            speed: Double = 1,
            repetition: Repetition = .once,
            scope: Scope? = nil,
            direction: Direction? = nil,
            breatheStyle: BreatheStyle? = nil,
            variableColorFill: VariableColorFill? = nil,
            reversing: Bool? = nil
        ) {
            self.speed = speed > 0 ? speed : 1
            self.repetition = Self.normalized(repetition)
            self.scope = scope
            self.direction = direction
            self.breatheStyle = breatheStyle
            self.variableColorFill = variableColorFill
            self.reversing = reversing
        }

        var isIndefinite: Bool {
            switch repetition {
            case .continuous, .periodic: true
            case .once, .count: false
            }
        }

        private static func normalized(_ repetition: Repetition) -> Repetition {
            switch repetition {
            case .count(let count) where count <= 1:
                .once
            case .periodic(let delay) where delay < 0:
                .periodic(delay: 0)
            default:
                repetition
            }
        }
    }
}

extension NWWhatsNewSymbol.EffectOptions {
    enum CodingKeys: String, CodingKey {
        case type, speed, `repeat`, scope, direction, style, fill, reversing
    }

    private enum PeriodicKeys: String, CodingKey {
        case every
    }

    init(from container: KeyedDecodingContainer<CodingKeys>) {
        self.init(
            speed: (try? container.decodeIfPresent(Double.self, forKey: .speed)) ?? 1,
            repetition: Self.repetition(from: container),
            scope: Self.lenient(Scope.self, container, .scope),
            direction: Self.lenient(Direction.self, container, .direction),
            breatheStyle: Self.lenient(BreatheStyle.self, container, .style),
            variableColorFill: Self.lenient(VariableColorFill.self, container, .fill),
            reversing: try? container.decodeIfPresent(Bool.self, forKey: .reversing)
        )
    }

    private static func repetition(from container: KeyedDecodingContainer<CodingKeys>) -> Repetition {
        if let count = try? container.decode(Int.self, forKey: .repeat) {
            return .count(count)
        }
        if let value = try? container.decode(String.self, forKey: .repeat) {
            switch value {
            case "continuous": return .continuous
            default: return .once
            }
        }
        if let periodic = try? container.nestedContainer(keyedBy: PeriodicKeys.self, forKey: .repeat),
           let delay = try? periodic.decode(Double.self, forKey: .every) {
            return .periodic(delay: delay)
        }
        return .once
    }

    private static func lenient<T: RawRepresentable>(
        _ type: T.Type,
        _ container: KeyedDecodingContainer<CodingKeys>,
        _ key: CodingKeys
    ) -> T? where T.RawValue == String {
        guard let raw = try? container.decodeIfPresent(String.self, forKey: key) else { return nil }
        return T(rawValue: raw)
    }
}
