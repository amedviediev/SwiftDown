# SwiftDown

A markdown editor component for your SwiftUI apps.

- Live preview directly in editor for most Markdown elements, without web-based preview.
- Built on Apple's [swift-markdown](https://github.com/swiftlang/swift-markdown) parser.
- Pure markdown, no proprietary format.
- macOS and iOS support.

Forked from [qeude/SwiftDown](https://github.com/qeude/SwiftDown) with the following changes:

- Replaced unmaintained [cmark](https://github.com/commonmark/cmark)/[Down](https://github.com/johnxnot/Down) dependency with Apple's `swift-markdown`
- Swift 6 strict concurrency support
- Inline highlighting via `NSTextStorage.processEditing()` (no debounce delay)
- Proper font trait merging (bold/italic inside headings preserves heading size)
- Plain text paste (preserves markdown syntax when pasting from rich text sources)

## Install

### Swift Package Manager

Either use Xcode to add the package dependency or add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/amedviediev/SwiftDown.git", from: "0.5.1")
```

## Usage

```swift
import SwiftDown
import SwiftUI

struct ContentView: View {
    @State private var text: String = ""

    var body: some View {
        SwiftDownEditor(text: $text)
            .insetsSize(40)
            .theme(Theme.BuiltIn.defaultDark.theme())
    }
}
```

## Themes

### Built-in themes

Two built-in themes are included: `defaultDark` and `defaultLight`.

### Custom themes

SwiftDown supports theming via JSON config files. See [default-dark.json](./Sources/SwiftDown/Resources/Themes/default-dark.json) for the format.

```swift
Theme(themePath: Bundle.main.path(forResource: "my-custom-theme", ofType: "json")!)
```

## Author

- Anton Medviediev — [GitHub](https://github.com/amedviediev)

Forked from [qeude/SwiftDown](https://github.com/qeude/SwiftDown) by Quentin Eude.
