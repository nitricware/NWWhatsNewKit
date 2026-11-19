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
                        .transition(.symbolEffect(.drawOn))
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
                .modifier(NWWhatsNewSymbolEffectModifier(effect: symbol.effect, trigger: trigger))
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
    let effect: NWWhatsNewSymbol.Effect?
    let trigger: Bool

    func body(content: Content) -> some View {
        switch effect {
        case .bounce: content.symbolEffect(.bounce, value: trigger)
        case .pulse: content.symbolEffect(.pulse, value: trigger)
        case .wiggle: content.symbolEffect(.wiggle, value: trigger)
        case .breathe: content.symbolEffect(.breathe, value: trigger)
        case .rotate: content.symbolEffect(.rotate, value: trigger)
        case .variableColor: content.symbolEffect(.variableColor, value: trigger)
        case .drawOn, nil: content
        }
    }
}
