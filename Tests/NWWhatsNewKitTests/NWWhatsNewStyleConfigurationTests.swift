//
//  NWWhatsNewStyleConfigurationTests.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI
import Testing
@testable import NWWhatsNewKit

private final class BundleToken {}
private var testBundle: Bundle { Bundle(for: BundleToken.self) }

@MainActor
@Suite("Style configuration")
struct NWWhatsNewStyleConfigurationTests {
    private final class Counter {
        var primary = 0
        var secondary = 0
        var secondaryAction = 0
    }

    private func configuration(
        items: [NWWhatsNewItem] = [],
        secondary: NWWhatsNewAction? = nil,
        counter: Counter = Counter()
    ) -> NWWhatsNewStyleConfiguration {
        NWWhatsNewStyleConfiguration(
            title: "title",
            items: items,
            primaryLabel: "primary",
            secondary: secondary,
            stringsTable: nil,
            bundle: testBundle,
            onPrimary: { counter.primary += 1 },
            onSecondary: { counter.secondary += 1 }
        )
    }

    // MARK: - Actions

    @Test("primaryAction calls the primary handler once")
    func primaryAction() {
        let counter = Counter()
        let sut = configuration(counter: counter)
        sut.primaryAction()
        #expect(counter.primary == 1)
        #expect(counter.secondary == 0)
    }

    @Test("secondaryAction calls the secondary handler once")
    func secondaryAction() {
        let counter = Counter()
        let sut = configuration(secondary: NWWhatsNewAction(label: "secondary") {}, counter: counter)
        sut.secondaryAction()
        #expect(counter.secondary == 1)
        #expect(counter.primary == 0)
    }

    @Test("hasSecondaryAction reflects the secondary action")
    func hasSecondaryAction() {
        #expect(!configuration().hasSecondaryAction)
        #expect(configuration(secondary: NWWhatsNewAction(label: "secondary") {}).hasSecondaryAction)
    }

    // MARK: - Items

    @Test("Items are passed through in order")
    func itemsPassedThrough() {
        let items = [
            NWWhatsNewItem(symbol: .init(name: "a"), title: "a"),
            NWWhatsNewItem(symbol: .init(name: "b"), title: "b"),
        ]
        #expect(configuration(items: items).items.map(\.id) == ["a", "b"])
    }

    @Test("description(for:) is nil without description")
    func descriptionNil() {
        let item = NWWhatsNewItem(symbol: .init(name: "a"), title: "a")
        #expect(configuration().description(for: item) == nil)
    }

    @Test("description(for:) is set with description")
    func descriptionSet() {
        let item = NWWhatsNewItem(symbol: .init(name: "a"), title: "a", description: "d")
        #expect(configuration().description(for: item) != nil)
    }

    @Test("image(for:) is nil without image")
    func imageNil() {
        let item = NWWhatsNewItem(symbol: .init(name: "a"), title: "a")
        #expect(configuration().image(for: item) == nil)
    }

    @Test("image(for:) is nil for an image missing from the bundle")
    func imageMissing() {
        let item = NWWhatsNewItem(symbol: .init(name: "a"), title: "a", image: "DoesNotExist")
        #expect(configuration().image(for: item) == nil)
    }

    @Test("imageDescription(for:) follows the item")
    func imageDescription() {
        let without = NWWhatsNewItem(symbol: .init(name: "a"), title: "a")
        let with = NWWhatsNewItem(symbol: .init(name: "a"), title: "a", imageDescription: "i")
        #expect(configuration().imageDescription(for: without) == nil)
        #expect(configuration().imageDescription(for: with) != nil)
    }
}
