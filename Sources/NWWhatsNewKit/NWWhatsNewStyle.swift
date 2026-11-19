//
//  NWWhatsNewStyle.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public protocol NWWhatsNewStyle: Sendable {
    associatedtype Body: View
    typealias Configuration = NWWhatsNewStyleConfiguration

    @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

struct AnyNWWhatsNewStyle: Sendable {
    private let make: @MainActor @Sendable (NWWhatsNewStyleConfiguration) -> AnyView

    init<S: NWWhatsNewStyle>(_ style: S) {
        make = { AnyView(style.makeBody(configuration: $0)) }
    }

    @MainActor func makeBody(configuration: NWWhatsNewStyleConfiguration) -> AnyView {
        make(configuration)
    }
}

extension EnvironmentValues {
    @Entry var whatsNewStyle = AnyNWWhatsNewStyle(NWWhatsNewStandardStyle())
}

extension View {
    public func whatsNewStyle<S: NWWhatsNewStyle>(_ style: S) -> some View {
        environment(\.whatsNewStyle, AnyNWWhatsNewStyle(style))
    }
}

extension NWWhatsNewStyle where Self == NWWhatsNewStandardStyle {
    public static var standard: Self { .init() }
}

extension NWWhatsNewStyle where Self == NWWhatsNewCompactStyle {
    public static var compact: Self { .init() }
}

extension NWWhatsNewStyle where Self == NWWhatsNewCarouselStyle {
    public static func carousel(nextLabel: LocalizedStringResource) -> Self {
        .init(nextLabel: nextLabel)
    }
}
