# NWWhatsNewKit

A SwiftUI "What's New" sheet driven by JSON release notes, with version tracking built on [NWVersionKit](https://github.com/nitricware/NWVersionKit).

- One JSON file per version, texts come from your own String Catalog
- Fallback from `x.y.z` to `x.y.0` to `x.0.0`
- Release notes that were already seen are never shown twice
- Full SF Symbols support: rendering modes, palettes, gradients, variable values, effects
- Three built-in styles (standard, compact, carousel) and support for custom styles
- Kiosk mode that always presents

## Requirements

- iOS 26+ / macOS 26+
- Swift 6.2+

## Installation

### Xcode

**File > Add Package Dependencies…** and enter:

```
https://github.com/nitricware/NWWhatsNewKit.git
```

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/nitricware/NWWhatsNewKit.git", from: "1.0.0")
],
targets: [
    .target(name: "YourTarget", dependencies: ["NWWhatsNewKit"])
]
```

## Setup

1. Create a folder named `WhatsNew` in your app's source folder with one JSON file per version: `4.0.0.json`, `4.1.0.json`, …
2. Add it to your project so it ends up in the app bundle **as a folder**:
   1. Right-click your app group > **Add Files to "YourApp"…** and select the `WhatsNew` folder.
   2. Choose **Action: Reference files in place** and **Groups: Create folders**, then click **Finish**.
   3. Select the `WhatsNew` folder in the project navigator and open the File Inspector (⌥⌘1).
   4. Set **Build Rules** to **Apply Once to Folder**. Otherwise the JSON files are copied flat into the bundle and the folder is not found.
   5. Under **Target Membership**, click **+** and add your **app target** only. Check this even if you selected the target while adding the folder.
3. Put the texts into a String Catalog, e.g. `WhatsNew.xcstrings`, and set the keys to **Managed: Manually** (see [String Catalog](#7-string-catalog)).

### Verify

- **Build Phases > Copy Bundle Resources** of your app target lists `WhatsNew` as a folder.
- After building, the folder exists in the app bundle (Products > Show in Finder > Show Package Contents):
  - iOS: `YourApp.app/WhatsNew/4.0.0.json`
  - macOS: `YourApp.app/Contents/Resources/WhatsNew/4.0.0.json`

If the sheet does not appear and the Settings button stays hidden, the folder is usually missing from the bundle or the JSON files were copied flat into its root.

## Release notes JSON

```json
{
  "items": [
    {
      "symbol": "icloud",
      "title": "whatsnew.v4.icloud.title",
      "description": "whatsnew.v4.icloud.description"
    },
    {
      "symbol": {
        "name": "map.fill",
        "rendering": "palette",
        "colors": ["pink", "#FFFFFF"],
        "gradient": true,
        "effect": "bounce"
      },
      "title": "whatsnew.v4.map.title",
      "description": "whatsnew.v4.map.description"
    }
  ]
}
```

### Item

| Key | Description | Default |
|---|---|---|
| `symbol` | SF Symbol name or symbol object (see below) | required |
| `title` | String Catalog key | required |
| `description` | String Catalog key | none |
| `image` | name of an image in the asset catalog, shown by the carousel style | none |
| `imageDescription` | String Catalog key used as accessibility label for `image` | `title` |

Items without `description` show the symbol and title only. Asset catalog images can be localized and support dark mode.

### Symbol

`symbol` is either an SF Symbol name or an object:

| Key | Values | Default |
|---|---|---|
| `name` | SF Symbol name | required |
| `rendering` | `monochrome`, `hierarchical`, `palette`, `multicolor` | `monochrome` |
| `colors` | up to 3 colors, each a string or an object with opacity (see below) | tint |
| `gradient` | `true`, `false` | `false` |
| `variableValue` | `0.0` – `1.0` | none |
| `variableMode` | `color`, `draw` | `color` |
| `effect` | `bounce`, `pulse`, `wiggle`, `breathe`, `rotate`, `variableColor`, `drawOn`, or an object with options (see below) | none |

By default, effects play once, shortly after the symbol appears. Use an object to configure them:

```json
"effect": {
  "type": "bounce",
  "direction": "up",
  "scope": "byLayer",
  "speed": 1.5,
  "repeat": 3
}
```

| Key | Values | Applies to | Default |
|---|---|---|---|
| `type` | an effect from the table above | all | required |
| `speed` | multiplier, e.g. `0.5` or `2` | all | `1` |
| `repeat` | a number, `"continuous"` or `{ "every": 2 }` (seconds between repetitions) | all except `drawOn` | once |
| `scope` | `byLayer`, `wholeSymbol`; `individually` for `drawOn` only | `bounce`, `pulse`, `wiggle`, `breathe`, `rotate`, `drawOn` | system default |
| `direction` | `up`, `down` (`bounce`, `wiggle`); `left`, `right`, `forward`, `backward` (`wiggle`); `clockwise`, `counterClockwise` (`wiggle`, `rotate`) | `bounce`, `wiggle`, `rotate` | system default |
| `style` | `pulse`, `plain` | `breathe` | system default |
| `fill` | `iterative`, `cumulative` | `variableColor` | system default |
| `reversing` | `true`, `false` | `variableColor` | system default |

Options that do not apply to the chosen effect are ignored, as are unknown values.

`drawOn` draws the symbol stroke by stroke, a symbol animation introduced with SF Symbols 7 (iOS 26 / macOS 26).

Unknown values fall back to the default. In `palette` mode the colors map to the primary, secondary and tertiary layer. `multicolor` ignores `colors`.

### Colors

A color string is resolved in this order:

1. Hex: `#RRGGBB` or `#RRGGBBAA` (with alpha)
2. SwiftUI system color: `red`, `orange`, `yellow`, `green`, `mint`, `teal`, `cyan`, `blue`, `indigo`, `purple`, `pink`, `brown`, `gray`, `white`, `black`, `primary`, `secondary`, `accent`
3. Color from the asset catalog in the given bundle
4. Otherwise: accent color

System color names take precedence over asset names.

A color can also be an object with an opacity between `0.0` and `1.0`:

```json
{ "color": "purple", "opacity": 0.6 }
```

Like in the SF Symbols app, a palette symbol can use up to three colors, each with its own opacity. Combined with gradients and a variable value:

```json
"symbol": {
  "name": "thermometer.medium",
  "rendering": "palette",
  "colors": ["gray", { "color": "purple", "opacity": 0.6 }, "red"],
  "gradient": true,
  "variableValue": 0.5
}
```

`variableValue` only has an effect on symbols that support variable values, such as `thermometer.medium`, `wifi` or `speaker.wave.3`. The SF Symbols app shows the **Variable** option for those.

## Which file is shown?

For app version `x.y.z` the tracker looks for:

1. `x.y.z.json`
2. `x.y.0.json`
3. `x.0.0.json`

If none exists, nothing is presented. The version of the file that was found is compared with the last seen version, so fallback notes are never shown twice:

| Last seen | App | Files | Presented |
|---|---|---|---|
| – | 4.0.0 | `4.0.0.json` | `4.0.0.json` |
| 4.0.0 | 4.5.1 | `4.5.0.json` | `4.5.0.json` |
| 4.1.0 | 4.1.1 | `4.1.0.json` | nothing |
| 4.0.0 | 4.1.0 | `4.0.0.json` | nothing |

## Usage

### 1. Tracker

By default the tracker looks for a `WhatsNew` folder in your app's resources, so there is nothing to configure:

```swift
NWWhatsNewTracker.shared.shouldPresent
```

`shared` creates a new tracker on each access. That is cheap, and all state lives in `UserDefaults`.

If your release notes live somewhere else, create your own tracker:

```swift
extension NWWhatsNewTracker {
    static var custom: NWWhatsNewTracker {
        NWWhatsNewTracker(
            releaseNotesDirectory: Bundle.main.resourceURL!.appending(path: "ReleaseNotes")
        )
    }
}
```

If the folder is missing, no release notes are found and nothing is presented. Nothing crashes.

### 2. Present automatically after an update

```swift
import SwiftUI
import NWWhatsNewKit

struct ContentView: View {
    @State private var isShowingWhatsNew = false
    @State private var isShowingTipJar = false

    var body: some View {
        MainView()
            .onAppear {
                if NWWhatsNewTracker.shared.shouldPresent {
                    isShowingWhatsNew = true
                }
            }
            .sheet(isPresented: $isShowingWhatsNew) {
                NWWhatsNewView(
                    tracker: .shared,
                    title: "whatsnew.title",
                    primaryLabel: "common.continue",
                    stringsTable: "WhatsNew",
                    secondary: NWWhatsNewAction(label: "whatsnew.tipjar") {
                        isShowingTipJar = true
                    }
                )
            }
            .sheet(isPresented: $isShowingTipJar) {
                TipJarView()
            }
    }
}
```

Both buttons call `markSeen()` and dismiss the sheet. The secondary action runs after dismissing.

### 3. Show again from Settings

Only offer the button if release notes exist for the current version, and allow swipe to dismiss:

```swift
struct SettingsView: View {
    @State private var isShowingWhatsNew = false

    var body: some View {
        Form {
            if NWWhatsNewTracker.shared.releaseNotesURL != nil {
                Section {
                    Button("settings.whatsnew") {
                        isShowingWhatsNew = true
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingWhatsNew) {
            NWWhatsNewView(
                tracker: .shared,
                title: "whatsnew.title",
                primaryLabel: "common.continue",
                stringsTable: "WhatsNew",
                dismissible: true
            )
        }
    }
}
```

### 4. List all release notes

`availableReleases` returns every release notes file up to the current app version, newest first. Use it to offer one button per release, e.g. in Settings:

```swift
struct SettingsView: View {
    @State private var selectedRelease: NWWhatsNewRelease?

    var body: some View {
        Form {
            Section("settings.whatsnew") {
                ForEach(NWWhatsNewTracker.shared.availableReleases) { release in
                    Button(release.version) {
                        selectedRelease = release
                    }
                }
            }
        }
        .sheet(item: $selectedRelease) { release in
            NWWhatsNewView(
                releaseNotesURL: release.url,
                title: "whatsnew.title",
                primaryLabel: "common.continue",
                stringsTable: "WhatsNew"
            )
        }
    }
}
```

Only files named like `x.y.z.json` are listed. Opening release notes this way does not call `markSeen()` and allows swipe to dismiss by default.

### 5. Kiosk mode

Present on every launch, e.g. for demo devices:

```swift
extension NWWhatsNewTracker {
    static var kiosk: NWWhatsNewTracker {
        NWWhatsNewTracker(policy: UserDefaults.standard.bool(forKey: "kiosk") ? .always : .onUpdate)
    }
}
```

`.always` still requires a release notes file for the current version. Make sure your trigger runs only once per launch, otherwise the sheet reappears right after closing.

### 6. Existing apps

If your app already stores the last seen version, pass its key so existing users don't see old release notes again:

```swift
NWWhatsNewTracker(key: "my.existing.lastversion")
```

The stored value must be a version string like `4.0.0`. To keep using `.shared`-style access, wrap it in your own tracker:

```swift
extension NWWhatsNewTracker {
    static var app: NWWhatsNewTracker {
        NWWhatsNewTracker(key: "my.existing.lastversion")
    }
}
```

### 7. String Catalog

Release notes keys only appear in JSON, so Xcode cannot find them in code and marks them as stale. Select them in the String Catalog editor and set **Managed** to **Manually** in the Attributes Inspector.

### 8. Complete example

This is how [pSTaRT](https://github.com/nitricware/pSTaRT) uses the package. It keeps its existing `UserDefaults` key, shows the sheet after updates with a tip jar button, and lists all release notes in Settings next to the app version.

**Tracker with the app's own key**

```swift
import NWWhatsNewKit

extension NWWhatsNewTracker {
    static var pstart: NWWhatsNewTracker {
        NWWhatsNewTracker(key: AppSettings.Key.onboardingLastVersion)
    }
}
```

**Main view: present after an update**

```swift
enum OverviewSheet: Identifiable {
    case settings, tipJar, whatsNew
    var id: Self { self }
}

struct Overview: View {
    @State private var sheet: OverviewSheet?

    var body: some View {
        content
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .settings:
                    SettingsView()
                case .tipJar:
                    TipJar()
                case .whatsNew:
                    NWWhatsNewView(
                        tracker: .pstart,
                        title: "whatsnew.title",
                        primaryLabel: "common.continue",
                        stringsTable: "WhatsNew",
                        secondary: NWWhatsNewAction(label: "whatsnew.tipjar") {
                            self.sheet = .tipJar
                        }
                    )
                }
            }
            .onAppear {
                guard sheet == nil else { return }
                if NWWhatsNewTracker.pstart.shouldPresent {
                    sheet = .whatsNew
                }
            }
    }
}
```

**Settings: app version and all release notes**

```swift
struct SettingsView: View {
    @State private var selectedRelease: NWWhatsNewRelease?

    var body: some View {
        Form {
            Section("settings.appinfo.title") {
                LabeledContent(
                    "settings.appversion",
                    value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
                )

                ForEach(NWWhatsNewTracker.pstart.availableReleases) { release in
                    Button {
                        selectedRelease = release
                    } label: {
                        LabeledContent("settings.whatsnew", value: release.version)
                    }
                }
            }
        }
        .sheet(item: $selectedRelease) { release in
            NWWhatsNewView(
                releaseNotesURL: release.url,
                title: "whatsnew.title",
                primaryLabel: "common.continue",
                stringsTable: "WhatsNew"
            )
        }
    }
}
```

**`WhatsNew/4.0.0.json`**

```json
{
  "items": [
    {
      "symbol": { "name": "icloud", "colors": ["cyan"] },
      "title": "whatsnew.v4.icloud.title",
      "description": "whatsnew.v4.icloud.description"
    },
    {
      "symbol": { "name": "map", "colors": ["pink"], "effect": "drawOn" },
      "title": "whatsnew.v4.map.title",
      "description": "whatsnew.v4.map.description"
    },
    {
      "symbol": { "name": "siri", "colors": ["yellow"] },
      "title": "whatsnew.v4.siri.title",
      "description": "whatsnew.v4.siri.description"
    }
  ]
}
```

## Styles

Apply a style directly to `NWWhatsNewView`, inside the `.sheet { … }`:

```swift
NWWhatsNewView(tracker: .shared, title: "whatsnew.title", primaryLabel: "common.continue")
    .whatsNewStyle(.compact)
```

| Style | Layout |
|---|---|
| `.standard` | symbol left, title and description right (default) |
| `.compact` | centered, large symbol above the title, no descriptions |
| `.carousel(nextLabel:)` | horizontally paging, one item per page with a large image (or symbol) above title and description |

### Carousel

```swift
.whatsNewStyle(.carousel(nextLabel: "common.next"))
```

- Each page shows the item's `image`. Without an image, the symbol is shown in a larger size.
- The primary button reads `nextLabel` until the last page, then shows your `primaryLabel` and the secondary button.
- Swiping between pages works as well.
- Pages scroll vertically if their content does not fit, e.g. with large text sizes.

### Custom styles

Conform to `NWWhatsNewStyle` and build the sheet from the configuration:

```swift
struct GridStyle: NWWhatsNewStyle {
    @MainActor func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.title
                .font(.largeTitle.bold())

            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(configuration.items) { item in
                    VStack {
                        configuration.symbol(for: item)
                            .font(.largeTitle)
                        configuration.title(for: item)
                    }
                }
            }

            Spacer()
            configuration.buttons
        }
    }
}

NWWhatsNewView(…)
    .whatsNewStyle(GridStyle())
```

The configuration provides:

| Member | Description |
|---|---|
| `title` | sheet title as `Text` |
| `items` | release notes items |
| `symbol(for:)` | symbol view with colors, rendering mode and effect applied |
| `title(for:)`, `description(for:)` | localized `Text` from your String Catalog |
| `image(for:)`, `imageDescription(for:)` | image from the asset catalog and its accessibility label |
| `buttons` | ready-made secondary and primary button with padding and background |
| `primaryButton`, `secondaryButton` | the same buttons individually |
| `primaryAction()`, `secondaryAction()` | the actions for your own buttons |
| `hasSecondaryAction` | whether a secondary action was provided |

#### Rules for custom styles

- **Always offer the primary action.** The sheet cannot be swiped away by default, so a style without `buttons`, `primaryButton` or a button calling `primaryAction()` locks the user in.
- **Use the provided actions.** `primaryAction()` and `secondaryAction()` mark the release notes as seen and dismiss the sheet. As a safety net, `NWWhatsNewView` also marks them as seen when the sheet disappears, so a style that only calls `dismiss` does not cause the sheet to reappear.
- **Mark `makeBody` as `@MainActor`.** The configuration is main actor isolated.
- **Keep state in a separate view.** `makeBody` cannot hold `@State`. Return your own view struct that owns the state, like the built-in carousel does with its current page.

## Options

### `NWWhatsNewTracker`

| Parameter | Description | Default |
|---|---|---|
| `releaseNotesDirectory` | folder containing the release notes JSON files | `WhatsNew` in `Bundle.main.resourceURL` |
| `key` | `UserDefaults` key for the last seen version | `NWWhatsNewKit.lastSeenVersion` |
| `defaults` | `UserDefaults` instance | `.standard` |
| `currentVersion` | app version | `CFBundleShortVersionString` |
| `policy` | `.onUpdate` or `.always` (kiosk mode) | `.onUpdate` |

`markSeen()` never overwrites a newer stored version, so `.always` is safe to combine with real updates.

### `NWWhatsNewView`

| Parameter | Description | Default |
|---|---|---|
| `tracker` | tracker providing the release notes and `markSeen()` | required (or `releaseNotesURL`) |
| `releaseNotesURL` | open a specific release notes file, without `markSeen()` | – |
| `title` | sheet title | required |
| `primaryLabel` | label of the primary button | required |
| `stringsTable` | String Catalog for item titles and descriptions | `nil` (`Localizable`) |
| `bundle` | bundle containing the String Catalog and asset catalog | `.main` |
| `secondary` | optional second button (`NWWhatsNewAction`) | `nil` |
| `dismissible` | allow swipe to dismiss | `false` (`true` with `releaseNotesURL`) |

The style is set with the `.whatsNewStyle(_:)` modifier, see [Styles](#styles).

`title`, `primaryLabel` and `secondary.label` are `LocalizedStringResource` and resolve in your app's `Localizable` catalog.

## Troubleshooting

In debug builds, release notes that cannot be decoded are logged to the console (`NWWhatsNewKit: could not load …`). The sheet then shows no items.

## Testing

Skip the sheet in UI tests by passing a high last seen version (use your own key if you set one):

```swift
app.launchArguments += ["-NWWhatsNewKit.lastSeenVersion", "999.0.0"]
```

## Versioning

NWWhatsNewKit follows [Semantic Versioning](https://semver.org).

Apple keeps adding symbol features: `drawOn`, for example, is new in iOS 26. Supporting such features can mean new cases in public enums like `NWWhatsNewSymbol.Effect`, which breaks code that switches over them exhaustively. Whenever a change could break existing code, the version is raised accordingly: a new major version for breaking changes, a minor version for additions that are safe.

## License

MIT, see [LICENSE](LICENSE).
