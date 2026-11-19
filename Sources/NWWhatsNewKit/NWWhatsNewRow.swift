//
//  NWWhatsNewRow.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

struct NWWhatsNewRow: View {
    let item: NWWhatsNewItem
    let configuration: NWWhatsNewStyleConfiguration

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            configuration.symbol(for: item)
                .font(.system(size: 28))
                .frame(width: 35, alignment: .center)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                configuration.title(for: item)
                    .font(.headline)
                if let description = configuration.description(for: item) {
                    description
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
