//
//  NWWhatsNewCompactStyle.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public struct NWWhatsNewCompactStyle: NWWhatsNewStyle {
    public init() {}

    @MainActor public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                configuration.title
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 48)
                    .padding(.bottom, 32)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 32) {
                    ForEach(configuration.items) { item in
                        NWWhatsNewCompactRow(item: item, configuration: configuration)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 36)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            configuration.buttons
        }
    }
}
