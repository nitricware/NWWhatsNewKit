//
//  NWWhatsNewRelease.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import Foundation

public struct NWWhatsNewRelease: Identifiable, Hashable, Sendable {
    public let version: String
    public let url: URL

    public var id: String { version }

    public init(version: String, url: URL) {
        self.version = version
        self.url = url
    }
}
