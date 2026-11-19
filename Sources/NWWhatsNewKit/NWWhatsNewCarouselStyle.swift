//
//  NWWhatsNewCarouselStyle.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public struct NWWhatsNewCarouselStyle: NWWhatsNewStyle {
    private let nextLabel: LocalizedStringResource

    public init(nextLabel: LocalizedStringResource) {
        self.nextLabel = nextLabel
    }

    @MainActor public func makeBody(configuration: Configuration) -> some View {
        NWWhatsNewCarousel(configuration: configuration, nextLabel: nextLabel)
    }
}
