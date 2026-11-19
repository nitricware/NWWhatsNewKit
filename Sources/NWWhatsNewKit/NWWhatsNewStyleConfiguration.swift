//
//  NWWhatsNewStyleConfiguration.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

@MainActor
public struct NWWhatsNewStyleConfiguration {
    public let items: [NWWhatsNewItem]

    private let titleResource: LocalizedStringResource
    private let primaryLabel: LocalizedStringResource
    private let secondary: NWWhatsNewAction?
    private let stringsTable: String?
    private let bundle: Bundle
    private let onPrimary: () -> Void
    private let onSecondary: () -> Void

    init(
        title: LocalizedStringResource,
        items: [NWWhatsNewItem],
        primaryLabel: LocalizedStringResource,
        secondary: NWWhatsNewAction?,
        stringsTable: String?,
        bundle: Bundle,
        onPrimary: @escaping () -> Void,
        onSecondary: @escaping () -> Void
    ) {
        self.titleResource = title
        self.items = items
        self.primaryLabel = primaryLabel
        self.secondary = secondary
        self.stringsTable = stringsTable
        self.bundle = bundle
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
    }

    // MARK: - Sheet

    public var title: Text {
        Text(titleResource)
    }

    // MARK: - Actions

    public var hasSecondaryAction: Bool {
        secondary != nil
    }

    public func primaryAction() {
        onPrimary()
    }

    public func secondaryAction() {
        onSecondary()
    }

    // MARK: - Buttons

    public var primaryButton: some View {
        Button(action: onPrimary) {
            Text(primaryLabel)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
    }

    @ViewBuilder
    public var secondaryButton: some View {
        if let secondary {
            Button(action: onSecondary) {
                Text(secondary.label)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
        }
    }

    public var buttons: some View {
        VStack(spacing: 14) {
            secondaryButton
            primaryButton
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.background)
    }

    // MARK: - Items

    public func symbol(for item: NWWhatsNewItem) -> some View {
        NWWhatsNewSymbolView(symbol: item.symbol, bundle: bundle)
    }

    public func title(for item: NWWhatsNewItem) -> Text {
        localized(item.title)
    }

    public func description(for item: NWWhatsNewItem) -> Text? {
        item.description.map(localized)
    }

    public func image(for item: NWWhatsNewItem) -> Image? {
        guard let name = item.image else { return nil }
        #if canImport(UIKit)
        guard UIImage(named: name, in: bundle, with: nil) != nil else { return nil }
        #elseif canImport(AppKit)
        guard bundle.image(forResource: name) != nil else { return nil }
        #endif
        return Image(name, bundle: bundle)
    }

    public func imageDescription(for item: NWWhatsNewItem) -> Text? {
        item.imageDescription.map(localized)
    }

    private func localized(_ key: String) -> Text {
        Text(LocalizedStringKey(key), tableName: stringsTable, bundle: bundle)
    }
}
