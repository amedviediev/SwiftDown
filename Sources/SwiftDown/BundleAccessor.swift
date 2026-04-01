import Foundation

private class BundleAnchor {}

extension Bundle {
    static var swiftDown: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleAnchor.self)
        #endif
    }
}
