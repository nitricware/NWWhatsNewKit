//
//  NWWhatsNewCompactRow.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 19.11.26.
//

import SwiftUI

struct NWWhatsNewCompactRow: View {
    let item: NWWhatsNewItem
    let configuration: NWWhatsNewStyleConfiguration

    var body: some View {
        VStack(spacing: 10) {
            configuration.symbol(for: item)
                .font(.system(size: 48))
                .frame(height: 56)
                .accessibilityHidden(true)

            configuration.title(for: item)
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
