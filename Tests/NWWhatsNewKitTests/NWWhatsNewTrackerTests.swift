import Foundation
import Testing
import NWWhatsNewKit

@Suite("NWWhatsNewTracker")
final class NWWhatsNewTrackerTests {
    private let suiteName = "NWWhatsNewKitTests.\(UUID().uuidString)"
    private let defaults: UserDefaults
    private let releaseNotesDirectory: URL

    init() throws {
        defaults = UserDefaults(suiteName: suiteName)!
        releaseNotesDirectory = FileManager.default.temporaryDirectory
            .appending(path: "NWWhatsNewKitTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: releaseNotesDirectory, withIntermediateDirectories: true)
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: releaseNotesDirectory)
    }

    private func tracker(
        current: String?,
        lastSeen: String? = nil,
        releaseNotes: [String]? = nil,
        policy: NWWhatsNewPolicy = .onUpdate,
        key: String = NWWhatsNewTracker.defaultKey
    ) -> NWWhatsNewTracker {
        if let lastSeen { defaults.set(lastSeen, forKey: key) }

        let files = releaseNotes ?? (current.map { [$0] } ?? [])
        for version in files {
            FileManager.default.createFile(
                atPath: releaseNotesDirectory.appending(path: "\(version).json").path(percentEncoded: false),
                contents: Data("{}".utf8)
            )
        }

        return NWWhatsNewTracker(
            releaseNotesDirectory: releaseNotesDirectory,
            key: key,
            defaults: defaults,
            currentVersion: current,
            policy: policy
        )
    }

    private var stored: String? {
        defaults.string(forKey: NWWhatsNewTracker.defaultKey)
    }

    // MARK: - .onUpdate

    @Test("Fresh install presents")
    func freshInstallPresents() {
        #expect(tracker(current: "4.0.0").shouldPresent)
    }

    @Test("Default policy is .onUpdate")
    func defaultPolicyIsOnUpdate() {
        #expect(tracker(current: "4.0.1", lastSeen: "4.0.0").shouldPresent)
    }

    @Test(
        ".onUpdate compares release notes version with last seen",
        arguments: [
            ("4.0.0", "4.0.1", true),
            ("4.0.0", "4.1.0", true),
            ("4.0.0", "5.0.0", true),
            ("4.0.0", "4.0.0", false),
            ("4.0.1", "4.0.0", false),
            ("5.0.0", "4.9.9", false),
        ]
    )
    func onUpdate(lastSeen: String, current: String, expected: Bool) {
        #expect(tracker(current: current, lastSeen: lastSeen).shouldPresent == expected)
    }

    @Test("Nil current version does not present")
    func nilVersionDoesNotPresent() {
        #expect(!tracker(current: nil).shouldPresent)
    }

    // MARK: - .always

    @Test(".always presents regardless of version", arguments: [nil, "3.0.0", "4.0.0", "999.0.0"])
    func alwaysPresents(lastSeen: String?) {
        #expect(tracker(current: "4.0.0", lastSeen: lastSeen, policy: .always).shouldPresent)
    }

    @Test(".always + markSeen never downgrades stored version")
    func alwaysDoesNotDowngrade() {
        let sut = tracker(current: "4.0.0", lastSeen: "999.0.0", policy: .always)
        sut.markSeen()
        #expect(stored == "999.0.0")
    }

    @Test(".always + markSeen still records a real update")
    func alwaysRecordsUpdate() {
        let sut = tracker(current: "4.0.0", lastSeen: "3.0.0", policy: .always)
        sut.markSeen()
        #expect(stored == "4.0.0")
        #expect(sut.shouldPresent)
    }

    @Test(".always still presents fallback release notes")
    func alwaysWithFallback() {
        let sut = tracker(current: "4.1.1", lastSeen: "999.0.0", releaseNotes: ["4.1.0"], policy: .always)
        #expect(sut.shouldPresent)
    }

    // MARK: - markSeen

    @Test("markSeen stores current version and stops presenting")
    func markSeenStores() {
        let sut = tracker(current: "4.0.0")
        sut.markSeen()
        #expect(stored == "4.0.0")
        #expect(!sut.shouldPresent)
    }

    @Test("markSeen does not overwrite same or newer version", arguments: ["4.0.0", "4.0.1", "999.0.0"])
    func markSeenNoOverwrite(lastSeen: String) {
        tracker(current: "4.0.0", lastSeen: lastSeen).markSeen()
        #expect(stored == lastSeen)
    }

    @Test("markSeen with nil version writes nothing")
    func markSeenNilVersion() {
        tracker(current: nil).markSeen()
        #expect(stored == nil)
    }

    // MARK: - Key

    @Test("Custom key is isolated from default key")
    func customKey() {
        let sut = tracker(current: "4.0.0", key: "custom.key")
        sut.markSeen()
        #expect(defaults.string(forKey: "custom.key") == "4.0.0")
        #expect(stored == nil)
    }

    // MARK: - Release notes resolution

    @Test("No JSON means no presentation", arguments: [NWWhatsNewPolicy.onUpdate, .always])
    func noReleaseNotesNoPresentation(policy: NWWhatsNewPolicy) {
        let sut = tracker(current: "4.1.1", releaseNotes: [], policy: policy)
        #expect(!sut.shouldPresent)
        #expect(sut.releaseNotesURL == nil)
    }

    @Test("Exact JSON is preferred")
    func exactPreferred() {
        let sut = tracker(current: "4.1.1", releaseNotes: ["4.0.0", "4.1.0", "4.1.1"])
        #expect(sut.releaseNotesURL?.lastPathComponent == "4.1.1.json")
    }

    @Test(
        "Fallback chain priority",
        arguments: [
            (["4.1.1", "4.1.0", "4.0.0"], "4.1.1.json"),
            (["4.1.0", "4.0.0"], "4.1.0.json"),
            (["4.0.0"], "4.0.0.json"),
        ]
    )
    func fallbackPriority(available: [String], expected: String) {
        let sut = tracker(current: "4.1.1", releaseNotes: available)
        #expect(sut.releaseNotesURL?.lastPathComponent == expected)
    }

    @Test("Falls back to x.y.0")
    func fallbackToMinor() {
        let sut = tracker(current: "4.1.1", lastSeen: "4.0.5", releaseNotes: ["4.1.0"])
        #expect(sut.releaseNotesURL?.lastPathComponent == "4.1.0.json")
        #expect(sut.shouldPresent)
    }

    @Test("Falls back to x.0.0")
    func fallbackToMajor() {
        let sut = tracker(current: "4.1.1", lastSeen: "3.9.0", releaseNotes: ["4.0.0"])
        #expect(sut.releaseNotesURL?.lastPathComponent == "4.0.0.json")
        #expect(sut.shouldPresent)
    }

    @Test("Does not fall back to previous major")
    func noFallbackToPreviousMajor() {
        let sut = tracker(current: "4.1.1", releaseNotes: ["3.0.0", "3.9.0"])
        #expect(sut.releaseNotesURL == nil)
        #expect(!sut.shouldPresent)
    }

    @Test("x.0.0 resolves to itself")
    func majorVersionSingleCandidate() {
        let sut = tracker(current: "4.0.0", releaseNotes: ["4.0.0"])
        #expect(sut.releaseNotesURL?.lastPathComponent == "4.0.0.json")
    }

    @Test("Minor fallback already seen is not presented again")
    func minorFallbackAlreadySeen() {
        let sut = tracker(current: "4.1.1", lastSeen: "4.1.0", releaseNotes: ["4.1.0"])
        #expect(!sut.shouldPresent)
    }

    @Test("Major fallback already seen is not presented again")
    func majorFallbackAlreadySeen() {
        let sut = tracker(current: "4.1.0", lastSeen: "4.0.0", releaseNotes: ["4.0.0"])
        #expect(!sut.shouldPresent)
    }

    @Test("After markSeen, fallback stays hidden")
    func fallbackAfterMarkSeen() {
        let sut = tracker(current: "4.1.1", lastSeen: "4.0.0", releaseNotes: ["4.1.0"])
        #expect(sut.shouldPresent)
        sut.markSeen()
        #expect(stored == "4.1.1")
        #expect(!sut.shouldPresent)
    }

    // MARK: - Overflow

    @Test("Overflow suffix is ignored for comparison")
    func overflowIgnoredForComparison() {
        #expect(!tracker(current: "4.0.0-beta", lastSeen: "4.0.0", releaseNotes: ["4.0.0"]).shouldPresent)
    }

    @Test("Overflow suffix resolves to plain version file")
    func overflowResolvesFile() {
        let sut = tracker(current: "4.1.1-beta", releaseNotes: ["4.1.1"])
        #expect(sut.releaseNotesURL?.lastPathComponent == "4.1.1.json")
    }

    // MARK: - Defaults

    @Test("Default release notes directory is WhatsNew in resources")
    func defaultDirectory() {
        let url = NWWhatsNewTracker.defaultReleaseNotesDirectory
        #expect(url.lastPathComponent == "WhatsNew")
        let parent = url.deletingLastPathComponent().path(percentEncoded: false)
        let resources = (Bundle.main.resourceURL ?? Bundle.main.bundleURL).path(percentEncoded: false)
        #expect(parent.trimmingCharacters(in: ["/"]) == resources.trimmingCharacters(in: ["/"]))
    }

    @Test("Shared tracker without release notes does not present")
    func sharedWithoutReleaseNotes() {
        #expect(NWWhatsNewTracker.shared.releaseNotesURL == nil)
    }

    // MARK: - Available releases

    @Test("Available releases are sorted newest first and exclude future versions")
    func availableReleasesSorted() {
        let sut = tracker(current: "4.1.1", releaseNotes: ["3.9.0", "4.0.0", "4.1.0", "5.0.0"])
        #expect(sut.availableReleases.map(\.version) == ["4.1.0", "4.0.0", "3.9.0"])
    }

    @Test("Available releases include the current version")
    func availableReleasesIncludeCurrent() {
        let sut = tracker(current: "4.1.0", releaseNotes: ["4.0.0", "4.1.0"])
        #expect(sut.availableReleases.map(\.version) == ["4.1.0", "4.0.0"])
    }

    @Test("Available releases ignore invalid file names and other extensions")
    func availableReleasesIgnoreInvalid() {
        let sut = tracker(current: "4.1.0", releaseNotes: ["4.0.0", "notes", "4.1", "4.1.0-beta"])
        FileManager.default.createFile(
            atPath: releaseNotesDirectory.appending(path: "4.1.0.txt").path(percentEncoded: false),
            contents: Data()
        )
        #expect(sut.availableReleases.map(\.version) == ["4.0.0"])
    }

    @Test("Available releases point to the JSON file")
    func availableReleasesURL() {
        let sut = tracker(current: "4.0.0", releaseNotes: ["4.0.0"])
        #expect(sut.availableReleases.first?.url.lastPathComponent == "4.0.0.json")
    }

    @Test("Missing directory has no available releases")
    func availableReleasesMissingDirectory() {
        let sut = NWWhatsNewTracker(
            releaseNotesDirectory: releaseNotesDirectory.appending(path: "missing"),
            defaults: defaults,
            currentVersion: "4.0.0"
        )
        #expect(sut.availableReleases.isEmpty)
    }
}
