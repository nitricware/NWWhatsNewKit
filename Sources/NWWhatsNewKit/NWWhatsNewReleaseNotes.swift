//
//  NWWhatsNewReleaseNotes.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import Foundation

public struct NWWhatsNewReleaseNotes: Decodable, Sendable {
    public let items: [NWWhatsNewItem]

    public static func load(from url: URL) throws -> NWWhatsNewReleaseNotes {
        try JSONDecoder().decode(NWWhatsNewReleaseNotes.self, from: Data(contentsOf: url))
    }
}
