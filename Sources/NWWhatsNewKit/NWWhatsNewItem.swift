//
//  NWWhatsNewItem.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import Foundation

public struct NWWhatsNewItem: Decodable, Identifiable, Sendable {
    public let symbol: NWWhatsNewSymbol
    public let title: String
    public let description: String?
    public let image: String?
    public let imageDescription: String?

    public var id: String { title }

    public init(
        symbol: NWWhatsNewSymbol,
        title: String,
        description: String? = nil,
        image: String? = nil,
        imageDescription: String? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.description = description
        self.image = image
        self.imageDescription = imageDescription
    }
}

extension NWWhatsNewItem {
    static let previewItems: [NWWhatsNewItem] = [
        NWWhatsNewItem(
            symbol: .init(
                name: "icloud",
                rendering: .hierarchical,
                colors: [.color(.cyan)],
                gradient: true,
                effect: .bounce,
                effectOptions: .init(repetition: .periodic(delay: 2), direction: .up)
            ),
            title: "iCloud Sync",
            description: "Your data, on all your devices."
        ),
        NWWhatsNewItem(
            symbol: .init(name: "map.fill", rendering: .palette, colors: [.named("pink"), .named("#FFFFFF")], effect: .drawOn),
            title: "Map",
            description: "See all patients on a map."
        ),
        NWWhatsNewItem(
            symbol: .init(name: "wifi", colors: [.named("yellow")], variableValue: 0.6, variableMode: .draw),
            title: "Siri"
        ),
    ]
}
