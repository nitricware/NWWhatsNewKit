//
//  NWWhatsNewView.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public struct NWWhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.whatsNewStyle) private var style

    private let title: LocalizedStringResource
    private let primaryLabel: LocalizedStringResource
    private let items: [NWWhatsNewItem]
    private let stringsTable: String?
    private let bundle: Bundle
    private let secondary: NWWhatsNewAction?
    private let dismissible: Bool
    private let onSeen: () -> Void

    public init(
        tracker: NWWhatsNewTracker,
        title: LocalizedStringResource,
        primaryLabel: LocalizedStringResource,
        stringsTable: String? = nil,
        bundle: Bundle = .main,
        secondary: NWWhatsNewAction? = nil,
        dismissible: Bool = false
    ) {
        self.init(
            items: Self.loadItems(from: tracker.releaseNotesURL),
            title: title,
            primaryLabel: primaryLabel,
            stringsTable: stringsTable,
            bundle: bundle,
            secondary: secondary,
            dismissible: dismissible,
            onSeen: tracker.markSeen
        )
    }

    public init(
        releaseNotesURL: URL,
        title: LocalizedStringResource,
        primaryLabel: LocalizedStringResource,
        stringsTable: String? = nil,
        bundle: Bundle = .main,
        dismissible: Bool = true
    ) {
        self.init(
            items: Self.loadItems(from: releaseNotesURL),
            title: title,
            primaryLabel: primaryLabel,
            stringsTable: stringsTable,
            bundle: bundle,
            dismissible: dismissible
        )
    }

    init(
        items: [NWWhatsNewItem],
        title: LocalizedStringResource,
        primaryLabel: LocalizedStringResource,
        stringsTable: String? = nil,
        bundle: Bundle = .main,
        secondary: NWWhatsNewAction? = nil,
        dismissible: Bool = false,
        onSeen: @escaping () -> Void = {}
    ) {
        self.items = items
        self.title = title
        self.primaryLabel = primaryLabel
        self.stringsTable = stringsTable
        self.bundle = bundle
        self.secondary = secondary
        self.dismissible = dismissible
        self.onSeen = onSeen
    }

    public var body: some View {
        style.makeBody(configuration: configuration)
            #if os(macOS)
            .frame(minWidth: 420, idealWidth: 480, minHeight: 520, idealHeight: 600)
            #endif
            .interactiveDismissDisabled(!dismissible)
            .onDisappear(perform: onSeen)
    }

    private var configuration: NWWhatsNewStyleConfiguration {
        NWWhatsNewStyleConfiguration(
            title: title,
            items: items,
            primaryLabel: primaryLabel,
            secondary: secondary,
            stringsTable: stringsTable,
            bundle: bundle,
            onPrimary: close,
            onSecondary: {
                close()
                secondary?.action()
            }
        )
    }

    private func close() {
        onSeen()
        dismiss()
    }

    private static func loadItems(from url: URL?) -> [NWWhatsNewItem] {
        guard let url else { return [] }
        do {
            return try NWWhatsNewReleaseNotes.load(from: url).items
        } catch {
            #if DEBUG
            print("NWWhatsNewKit: could not load \(url.lastPathComponent): \(error)")
            #endif
            return []
        }
    }
}

#Preview("Standard") {
    NWWhatsNewView(
        items: NWWhatsNewItem.previewItems,
        title: "What's New",
        primaryLabel: "Continue",
        secondary: NWWhatsNewAction(label: "Tip Jar") {}
    )
}

#Preview("Compact") {
    NWWhatsNewView(
        items: NWWhatsNewItem.previewItems,
        title: "What's New in pSTaRT",
        primaryLabel: "Continue"
    )
    .whatsNewStyle(.compact)
}

#Preview("Carousel") {
    NWWhatsNewView(
        items: NWWhatsNewItem.previewItems,
        title: "What's New",
        primaryLabel: "Continue",
        secondary: NWWhatsNewAction(label: "Tip Jar") {}
    )
    .whatsNewStyle(.carousel(nextLabel: "Next"))
}
