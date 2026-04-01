# SwiftDown

[![codecov](https://codecov.io/gh/qeude/SwiftDown/branch/main/graph/badge.svg?token=RB6K3Q5QIO)](https://codecov.io/gh/qeude/SwiftDown)

## 📖 Description

A markdown editor component for your SwiftUI apps.

- 🎉 Live preview directly in editor for most of Markdown elements, without web based preview.
- ⚡️ Fast, built on top of Apple's [swift-markdown](https://github.com/swiftlang/swift-markdown).
- 🗒 Pure markdown, no proprietary format.
- 💻:📱 macOS and iOS support.

<div align=center><img src="resources/demo.gif" align=center height="500"></div>

## 🛠️ Install

### 📦 Swift Package Manager

Either use Xcode to add the package dependency or add the following dependency to your Package.swift:

```swift
.package(url: "https://github.com/amedviediev/SwiftDown.git", from: "0.5.1")
```

## 🔧 Usage

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

## 🖌️ Themes

### 🖼 Built-in themes

#### Default Dark

<img src="resources/default-dark-theme.png" height="400">

#### Default Light

<img src="resources/default-light-theme.png" height="400">

### 🧑‍🎨 Custom themes

SwiftDown supports theming by using config `.json` files as [this one](./Sources/SwiftDown/Resources/Themes/default-dark.json).
Then init your custom theme as below.

```swift
Theme(themePath: Bundle.main.path(forResource: "my-custom-theme", ofType: "json"))
```

## 👨🏻‍💻 Author

- Anton Medviediev — [GitHub](https://github.com/amedviediev)

Forked from [qeude/SwiftDown](https://github.com/qeude/SwiftDown)
