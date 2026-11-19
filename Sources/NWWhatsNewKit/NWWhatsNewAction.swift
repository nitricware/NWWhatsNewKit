//
//  NWWhatsNewAction.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 18.11.26.
//

import SwiftUI

public struct NWWhatsNewAction {
    public let label: LocalizedStringResource
    public let action: () -> Void

    public init(label: LocalizedStringResource, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
}
