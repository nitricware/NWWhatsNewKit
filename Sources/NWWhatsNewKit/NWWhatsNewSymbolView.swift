//
//  NWWhatsNewSymbolView.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

struct NWWhatsNewSymbolView: View {
    let symbol: NWWhatsNewSymbol
    let bundle: Bundle

    @State private var trigger = false
    @State private var isDrawn = false

    var body: some View {
        if symbol.effect == .drawOn {
            ZStack {
                image
                    .hidden()

                if isDrawn {
                    image
                        .transition(.symbolEffect(drawOnEffect, options: symbolEffectOptions))
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(400))
                withAnimation {
                    isDrawn = true
                }
            }
        } else {
            image
                .modifier(NWWhatsNewSymbolEffectModifier(symbol: symbol, trigger: trigger))
                .task {
                    guard symbol.effect != nil else { return }
                    try? await Task.sleep(for: .milliseconds(400))
                    trigger.toggle()
                }
        }
    }

    private var image: some View {
        Image(systemName: symbol.name, variableValue: symbol.variableValue)
            .symbolRenderingMode(renderingMode)
            .symbolColorRenderingMode(symbol.gradient ? .gradient : .flat)
            .symbolVariableValueMode(symbol.variableMode == .draw ? .draw : .color)
            .modifier(NWWhatsNewSymbolColorsModifier(symbol: symbol, bundle: bundle))
    }

    private var drawOnEffect: DrawOnSymbolEffect {
        switch symbol.effectOptions.scope {
        case .byLayer: .drawOn.byLayer
        case .wholeSymbol: .drawOn.wholeSymbol
        case .individually: .drawOn.individually
        case nil: .drawOn
        }
    }

    private var symbolEffectOptions: SymbolEffectOptions {
        symbol.effectOptions.symbolEffectOptions
    }

    private var renderingMode: SymbolRenderingMode {
        switch symbol.rendering {
        case .monochrome: .monochrome
        case .hierarchical: .hierarchical
        case .palette: .palette
        case .multicolor: .multicolor
        }
    }
}

private struct NWWhatsNewSymbolColorsModifier: ViewModifier {
    let symbol: NWWhatsNewSymbol
    let bundle: Bundle

    func body(content: Content) -> some View {
        let c = symbol.colors.map { $0.resolve(in: bundle) }
        if symbol.rendering == .multicolor {
            content
        } else {
            switch c.count {
            case 0: content.foregroundStyle(.tint)
            case 1: content.foregroundStyle(c[0])
            case 2: content.foregroundStyle(c[0], c[1])
            default: content.foregroundStyle(c[0], c[1], c[2])
            }
        }
    }
}

private struct NWWhatsNewSymbolEffectModifier: ViewModifier {
    let symbol: NWWhatsNewSymbol
    let trigger: Bool

    private var options: NWWhatsNewSymbol.EffectOptions { symbol.effectOptions }

    func body(content: Content) -> some View {
        switch symbol.effect {
        case .bounce: apply(bounce, to: content)
        case .pulse: apply(pulse, to: content)
        case .wiggle: apply(wiggle, to: content)
        case .breathe: apply(breathe, to: content)
        case .rotate: apply(rotate, to: content)
        case .variableColor: apply(variableColor, to: content)
        case .drawOn, nil: content
        }
    }

    @ViewBuilder
    private func apply<E: DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect>(
        _ effect: E,
        to content: Content
    ) -> some View {
        if options.isIndefinite {
            content.symbolEffect(effect, options: options.symbolEffectOptions, isActive: trigger)
        } else {
            content.symbolEffect(effect, options: options.symbolEffectOptions, value: trigger)
        }
    }

    private var bounce: BounceSymbolEffect {
        var effect = BounceSymbolEffect.bounce
        switch options.direction {
        case .up: effect = effect.up
        case .down: effect = effect.down
        default: break
        }
        switch options.scope {
        case .byLayer: effect = effect.byLayer
        case .wholeSymbol: effect = effect.wholeSymbol
        default: break
        }
        return effect
    }

    private var pulse: PulseSymbolEffect {
        switch options.scope {
        case .byLayer: .pulse.byLayer
        case .wholeSymbol: .pulse.wholeSymbol
        default: .pulse
        }
    }

    private var wiggle: WiggleSymbolEffect {
        var effect = WiggleSymbolEffect.wiggle
        switch options.direction {
        case .up: effect = effect.up
        case .down: effect = effect.down
        case .left: effect = effect.left
        case .right: effect = effect.right
        case .forward: effect = effect.forward
        case .backward: effect = effect.backward
        case .clockwise: effect = effect.clockwise
        case .counterClockwise: effect = effect.counterClockwise
        case nil: break
        }
        switch options.scope {
        case .byLayer: effect = effect.byLayer
        case .wholeSymbol: effect = effect.wholeSymbol
        default: break
        }
        return effect
    }

    private var breathe: BreatheSymbolEffect {
        var effect = BreatheSymbolEffect.breathe
        switch options.breatheStyle {
        case .pulse: effect = effect.pulse
        case .plain: effect = effect.plain
        case nil: break
        }
        switch options.scope {
        case .byLayer: effect = effect.byLayer
        case .wholeSymbol: effect = effect.wholeSymbol
        default: break
        }
        return effect
    }

    private var rotate: RotateSymbolEffect {
        var effect = RotateSymbolEffect.rotate
        switch options.direction {
        case .clockwise: effect = effect.clockwise
        case .counterClockwise: effect = effect.counterClockwise
        default: break
        }
        switch options.scope {
        case .byLayer: effect = effect.byLayer
        case .wholeSymbol: effect = effect.wholeSymbol
        default: break
        }
        return effect
    }

    private var variableColor: VariableColorSymbolEffect {
        var effect = VariableColorSymbolEffect.variableColor
        switch options.variableColorFill {
        case .iterative: effect = effect.iterative
        case .cumulative: effect = effect.cumulative
        case nil: break
        }
        if let reversing = options.reversing {
            effect = reversing ? effect.reversing : effect.nonReversing
        }
        return effect
    }
}

extension NWWhatsNewSymbol.EffectOptions {
    var symbolEffectOptions: SymbolEffectOptions {
        var result: SymbolEffectOptions = .default
        switch repetition {
        case .once:
            result = result.nonRepeating
        case .count(let count):
            result = result.repeat(.periodic(count))
        case .continuous:
            result = result.repeat(.continuous)
        case .periodic(let delay):
            result = result.repeat(.periodic(delay: delay))
        }
        if speed != 1 {
            result = result.speed(speed)
        }
        return result
    }
}
