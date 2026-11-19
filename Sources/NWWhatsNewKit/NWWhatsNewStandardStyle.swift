//
//  NWWhatsNewStandardStyle.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public struct NWWhatsNewStandardStyle: NWWhatsNewStyle {
    public init() {}

    @MainActor public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                configuration.title
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: 24) {
                    ForEach(configuration.items) { item in
                        NWWhatsNewRow(item: item, configuration: configuration)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 36)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            configuration.buttons
        }
    }
}
