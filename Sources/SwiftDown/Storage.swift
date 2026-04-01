//
//  Editor.swift
//
//
//  Created by Quentin Eude on 10/03/2021.
//
import Combine

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

struct EditedText: Equatable {
  let string: String
  let editedRange: NSRange
}

public class Storage: NSTextStorage {
  public var theme: Theme? {
    didSet {
      self.beginEditing()
      self.applyStyles()
      self.endEditing()
    }
  }
  public var markdowner: (String, Int) -> [MarkdownNode] = { _,_  in [] }
  public var applyMarkdown: (MarkdownNode) -> [NSAttributedString.Key: Any] = { _ in [:] }
  public var applyBody: () -> [NSAttributedString.Key: Any] = { [:] }
  var cancellables = Set<AnyCancellable>()
  let subj = PassthroughSubject<EditedText, Never>()

  var backingStore = NSTextStorage()

  override public var string: String {
    return backingStore.string
  }

  override public init() {
    super.init()
  }

  override public init(attributedString attrStr: NSAttributedString) {
    super.init(attributedString: attrStr)
    backingStore.setAttributedString(attrStr)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required public init(itemProviderData data: Data, typeIdentifier: String) throws {
    fatalError("init(itemProviderData:typeIdentifier:) has not been implemented")
  }

  #if os(macOS)
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
      fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }

    required public init?(
      pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType
    ) {
      fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
  #endif

  override public func attributes(
    at location: Int, longestEffectiveRange range: NSRangePointer?, in rangeLimit: NSRange
  ) -> [NSAttributedString.Key: Any] {
    return backingStore.attributes(at: location, longestEffectiveRange: range, in: rangeLimit)
  }

  override public func replaceCharacters(in range: NSRange, with str: String) {
    self.beginEditing()
    backingStore.replaceCharacters(in: range, with: str)
    let len = (str as NSString).length
    let change = len - range.length
    self.edited([.editedCharacters], range: range, changeInLength: change)
    self.endEditing()
  }

  public override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
    self.beginEditing()
    backingStore.setAttributes(attrs, range: range)
    self.edited(.editedAttributes, range: range, changeInLength: 0)
    self.endEditing()
  }

  public override func attributes(at location: Int, effectiveRange range: NSRangePointer?)
    -> [NSAttributedString.Key: Any] {
    return backingStore.attributes(at: location, effectiveRange: range)
  }

  override public func processEditing() {
    super.processEditing()
    if editedMask.contains(.editedCharacters) {
      applyStyles(editedRange: editedRange)
    }
  }

  func applyStyles(editedRange: NSRange? = nil) {
    let paragraphNSRange = self.string.paragraph(for: editedRange)
    let paragraphRange = Range(paragraphNSRange, in: self.string)
    let paragraph: String
    if let paragraphRange = paragraphRange {
      paragraph = String(self.string[paragraphRange])
    } else {
      paragraph = self.string
    }
    let md = markdowner(paragraph, paragraphNSRange.lowerBound)
    setAttributes(applyBody(), range: paragraphNSRange)

    // Apply block-level styles (headings, quotes, etc.) first, then inline styles (bold, italic)
    // so that inline traits merge into the block-level font instead of replacing it.
    let blockTypes: Set<MarkdownNode.MarkdownType> = [
      .header1, .header2, .header3, .header4, .header5, .header6, .quote, .codeBlock, .list
    ]
    let inlineTypes: Set<MarkdownNode.MarkdownType> = [.bold, .italic]

    let blockNodes = md.filter { blockTypes.contains($0.type) }
    let inlineNodes = md.filter { inlineTypes.contains($0.type) }
    let otherNodes = md.filter { !blockTypes.contains($0.type) && !inlineTypes.contains($0.type) }

    for node in blockNodes {
      addAttributes(applyMarkdown(node), range: node.range)
    }
    for node in otherNodes {
      addAttributes(applyMarkdown(node), range: node.range)
    }
    for node in inlineNodes {
      mergeInlineStyle(applyMarkdown(node), range: node.range)
    }
    self.edited(.editedAttributes, range: paragraphNSRange, changeInLength: 0)
  }

  private func mergeInlineStyle(_ attrs: [NSAttributedString.Key: Any], range: NSRange) {
    guard range.location + range.length <= self.length else { return }
    guard let newFont = attrs[.font] as? UniversalFont else {
      addAttributes(attrs, range: range)
      return
    }

    // Apply non-font attributes directly
    var nonFontAttrs = attrs
    nonFontAttrs.removeValue(forKey: .font)
    if !nonFontAttrs.isEmpty {
      addAttributes(nonFontAttrs, range: range)
    }

    // For the font, merge traits into whatever font is already there
    enumerateAttribute(.font, in: range, options: []) { existingValue, subRange, _ in
      let existingFont = existingValue as? UniversalFont ?? newFont
      let existingSize = existingFont.pointSize
      let mergedFont = mergeFontTraits(base: existingFont, from: newFont, size: existingSize)
      addAttributes([.font: mergedFont], range: subRange)
    }
  }

  private func mergeFontTraits(base: UniversalFont, from source: UniversalFont, size: CGFloat) -> UniversalFont {
    #if os(iOS)
    let existingTraits = base.fontDescriptor.symbolicTraits
    let newTraits = source.fontDescriptor.symbolicTraits
    let merged = UIFontDescriptor.SymbolicTraits(rawValue: existingTraits.rawValue | newTraits.rawValue)
    if let descriptor = base.fontDescriptor.withSymbolicTraits(merged) {
      return UIFont(descriptor: descriptor, size: size)
    }
    return base.withSize(size)
    #elseif os(macOS)
    let existingTraits = base.fontDescriptor.symbolicTraits
    let newTraits = source.fontDescriptor.symbolicTraits
    let merged = NSFontDescriptor.SymbolicTraits(rawValue: existingTraits.rawValue | newTraits.rawValue)
    let descriptor = base.fontDescriptor.withSymbolicTraits(merged)
    return NSFont(descriptor: descriptor, size: size) ?? base.withSize(size)
    #endif
  }
}
