//
//  RichTextView.swift
//  Cryb
//
//  Created by Pierre-Antoine Fagniez on 04/11/2022.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public struct RichText: View {

    private let textStyleManager: TextStyleManager

    private var font: UIFont?

    public init(text: String?, font: UIFont? = UIFont.systemFont(ofSize: 14)) {
        self.font = font
        textStyleManager = TextStyleManager(text: text)
    }

    public var body: some View {
        RichTextEditor(textStyleManager: textStyleManager, font: font, isEditable: false)
    }
}

@available(iOS 13.0, *)
public struct RichTextEditor: View {
    @ObservedObject public var textStyleManager: TextStyleManager
    var public font: UIFont?
    var public isEditable = true
    var public onTextSelected: ((NSRange) -> Void)?

    public var body: some View {
        UIRichTextEditor(text: $textStyleManager.nsString, range: $textStyleManager.range, font: font, isEditable: isEditable)
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 15)
    }

    private struct UIRichTextEditor: UIViewRepresentable {
        @Binding var text: NSAttributedString
        @Binding var range: NSRange
        var font: UIFont?
        var isEditable = true

        func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()

            textView.autocapitalizationType = .sentences
            textView.isScrollEnabled = true
            textView.isSelectable = true
            textView.isEditable = isEditable
            textView.delegate = context.coordinator
            textView.backgroundColor = .clear
            textView.font = font

            return textView
        }

        func updateUIView(_ uiView: UITextView, context: Context) {
            uiView.attributedText = text
            uiView.selectedRange = range
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text, range: $range)
        }

        class Coordinator: NSObject, UITextViewDelegate {
            var text: Binding<NSAttributedString>
            var range: Binding<NSRange>

            init(text: Binding<NSAttributedString>, range: Binding<NSRange>) {
                self.text = text
                self.range = range
            }

            func textViewDidChange(_ textView: UITextView) {
                text.wrappedValue = textView.attributedText
            }

            func textViewDidChangeSelection(_ textView: UITextView) {
                range.wrappedValue = textView.selectedRange
            }
        }
    }
}

@available(iOS 13.0, *)
extension String {

    public var asAttributedString: NSAttributedString? {
        let data = Data(utf8)
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString
        } catch let error as NSError {
            print("\(error)")
            return nil
        }
    }
}

@available(iOS 13.0, *)
extension NSAttributedString {
    public var asHtml: String? {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try data(from: NSMakeRange(0, length), documentAttributes: documentAttributes)
            if let htmlString = String(data: htmlData, encoding: String.Encoding.utf8) {
                return htmlString
            }
        } catch {
            
        }
        return nil
    }
}
