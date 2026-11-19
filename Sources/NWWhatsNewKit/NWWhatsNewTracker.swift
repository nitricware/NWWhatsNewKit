//
//  NWWhatsNewTracker.swift
//  NWWhatsNewKit
//
//  Created by Kurt Frey on 17.11.26.
//

import Foundation
import NWVersionKit

public struct NWWhatsNewTracker {
    public static let defaultKey = "NWWhatsNewKit.lastSeenVersion"

    public static var defaultReleaseNotesDirectory: URL {
        (Bundle.main.resourceURL ?? Bundle.main.bundleURL).appending(path: "WhatsNew")
    }

    public static var shared: NWWhatsNewTracker {
        NWWhatsNewTracker()
    }

    private let releaseNotesDirectory: URL
    private let key: String
    private let defaults: UserDefaults
    private let currentVersion: NWVersion
    private let policy: NWWhatsNewPolicy

    public init(
        releaseNotesDirectory: URL = defaultReleaseNotesDirectory,
        key: String = defaultKey,
        defaults: UserDefaults = .standard,
        currentVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        policy: NWWhatsNewPolicy = .onUpdate
    ) {
        self.releaseNotesDirectory = releaseNotesDirectory
        self.key = key
        self.defaults = defaults
        self.currentVersion = NWVersion(versionString: currentVersion)
        self.policy = policy
    }

    public var releaseNotesURL: URL? {
        resolvedReleaseNotes?.url
    }

    public var availableReleases: [NWWhatsNewRelease] {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: releaseNotesDirectory,
            includingPropertiesForKeys: nil
        )) ?? []

        return files
            .filter { $0.pathExtension == "json" }
            .map { NWWhatsNewRelease(version: $0.deletingPathExtension().lastPathComponent, url: $0) }
            .filter { $0.version.wholeMatch(of: #/\d+\.\d+\.\d+/#) != nil }
            .filter { currentVersion.compare(with: $0.version) != .older }
            .sorted { NWVersion(versionString: $0.version).compare(with: $1.version) == .newer }
    }

    public var shouldPresent: Bool {
        guard let releaseNotes = resolvedReleaseNotes else { return false }

        switch policy {
        case .always:
            return true
        case .onUpdate:
            return NWVersion(versionString: releaseNotes.version)
                .compare(with: lastSeenVersion) == .newer
        }
    }

    public func markSeen() {
        guard currentVersion.compare(with: lastSeenVersion) == .newer else { return }
        defaults.set(currentVersion.version.string, forKey: key)
    }

    private var lastSeenVersion: String {
        defaults.string(forKey: key) ?? "0.0.0"
    }

    private var candidateVersions: [String] {
        let v = currentVersion.version
        let chain = [
            "\(v.major).\(v.minor).\(v.patch)",
            "\(v.major).\(v.minor).0",
            "\(v.major).0.0",
        ]
        return chain.reduce(into: []) { result, version in
            if !result.contains(version) { result.append(version) }
        }
    }

    private var resolvedReleaseNotes: (version: String, url: URL)? {
        for version in candidateVersions {
            let url = releaseNotesDirectory.appending(path: "\(version).json")
            if FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) {
                return (version, url)
            }
        }
        return nil
    }
}
