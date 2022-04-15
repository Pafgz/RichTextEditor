//
//  TextStyleManager.swift
//  
//
//  Created by Pierre-Antoine Fagniez on 11/04/2022.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
public class TextStyleManager: ObservableObject {
    @Published var nsString: NSAttributedString
    @Published var range: NSRange
    
    private let defaultFont: UIFont
    private let boldFont: UIFont
    private let italicFont: UIFont
    
    public init(text: String?, defaultFont: UIFont = UIFont.systemFont(ofSize: 14), boldFont: UIFont? = UIFont.systemFont(ofSize: 14, weight: .bold), italicFont: UIFont? = nil) {
        self.defaultFont = defaultFont
        self.boldFont = boldFont ?? defaultFont
        self.italicFont = italicFont ?? defaultFont
        var lastIndex = (text?.count ?? 0)
        lastIndex = (lastIndex <= 0) ? 0 : lastIndex - 1
        range = NSRange(location: lastIndex, length: lastIndex)
        nsString = text?.asAttributedString ?? NSAttributedString()
    }

    public func changeStyle(_ style: TextStyleType) {
        switch style {
        case let .size(size):
            changeSize(size: size)
        case .bold:
            toggleBold()
        case .underline:
            setUnderline()
        case .strikeThrough:
            setStrikeThrough()
        }
    }

    private func changeSize(size: CGFloat) {
        let mutableText = NSMutableAttributedString(attributedString: nsString)
        mutableText.enumerateAttribute(.font, in: range) { value, range, stop in
            if let font = value as? UIFont {
                let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                mutableText
                    .addAttribute(
                        .font,
                        value: isBold ? boldFont.withSize(size) : defaultFont.withSize(size),
                        range: range
                    )
            }
        }
        nsString = mutableText
    }

    private func toggleBold() {
        let mutableText = NSMutableAttributedString(attributedString: nsString)
        mutableText.enumerateAttribute(.font, in: range) { value, range, stop in
            if let font = value as? UIFont {
                let size = font.pointSize
                // make sure this font is actually bold
                let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                mutableText
                    .addAttribute(
                        .font,
                        value: isBold ? defaultFont.withSize(size) : boldFont.withSize(size),
                        range: range
                    )
            }
        }
        nsString = mutableText
    }
    
    private func setUnderline() {
        let mutableText = NSMutableAttributedString(attributedString: nsString)
        mutableText.enumerateAttributes(in: range) { dict, range, value in
            if dict.keys.contains(.underlineStyle) {
                mutableText.removeAttribute(NSAttributedString.Key.underlineStyle, range: range)
            } else { mutableText.addAttribute(
                .underlineStyle,
                value: 1,
                range: range
            ) }
        }
        nsString = mutableText
    }

    private func setStrikeThrough() {
        let mutableText = NSMutableAttributedString(attributedString: nsString)
        mutableText.enumerateAttributes(in: range) { dict, range, value in
            if dict.keys.contains(.strikethroughStyle) {
                mutableText.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: range)
            } else { mutableText.addAttribute(
                .strikethroughStyle,
                value: 1,
                range: range
            ) }
        }
        nsString = mutableText
    }
}

public enum TextStyleType {
    case size(_ size: CGFloat), bold, underline, strikeThrough
}
