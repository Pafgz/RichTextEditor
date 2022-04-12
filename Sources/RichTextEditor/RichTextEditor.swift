//
//  RichTextView.swift
//  Cryb
//
//  Created by Pierre-Antoine Fagniez on 04/11/2022.
//

import Foundation
import SwiftUI
#if !os(macOS)
import UIKit

@available(iOS 13.0, *)
struct RichText: View {
    @State private var nsStr: NSAttributedString
    @State private var range = NSRange(location: 0, length: 0)

    private var font: UIFont?

    init(text: String?, font: UIFont? = UIFont.systemFont(ofSize: 14)) {
        nsStr = text?.asAttributedString ?? NSAttributedString()
        self.font = font
    }

    var body: some View {
        RichTextEditor(text: $nsStr, range: $range, font: font, isEditable: false)
    }
}

@available(iOS 13.0, *)
struct RichTextEditor: View {
    @Binding var text: NSAttributedString
    @Binding var range: NSRange
    var font: UIFont?
    var isEditable = true
    var onTextSelected: ((NSRange) -> Void)?

    var body: some View {
        UIRichTextEditor(text: $text, range: $range, font: font, isEditable: isEditable)
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

#endif


@available(iOS 13.0, *)
extension String {
    var asAttributedString: NSAttributedString? {
        let data = Data(utf8)
        do {
            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attributedString
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}

@available(iOS 13.0, *)
extension NSAttributedString {
    var asHtml: String? {
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
