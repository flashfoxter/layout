//  Copyright © 2017 Schibsted. All rights reserved.

import UIKit

// Flatten an array of dictionaries
func merge(_ dictionaries: [[String: Any]]) -> [String: Any] {
    var result = [String: Any]()
    for dict in dictionaries {
        for (key, value) in dict {
            result[key] = value
        }
    }
    return result
}

private let classPrefix = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "")
    .replacingOccurrences(of: "[^a-zA-Z0-9_]", with: "_", options: .regularExpression)

// Get a class by name, adding project prefix if needed
func classFromString(_ name: String) -> AnyClass? {
    return NSClassFromString(name) ?? NSClassFromString("\(classPrefix).\(name)")
}

// Get the name of a class, without project prefix
func nameOfClass(_ name: AnyClass) -> String {
    let name = NSStringFromClass(name)
    let prefix = "\(classPrefix)."
    if name.hasPrefix(prefix) {
        return String(name[prefix.endIndex...])
    }
    return name
}

// Get a protocol by name
func protocolFromString(_ name: String) -> Protocol? {
    return NSProtocolFromString(name) ?? NSProtocolFromString("\(classPrefix).\(name)")
}

// Internal API for converting a path to a full URL
func urlFromString(_ path: String, relativeTo baseURL: URL? = nil) -> URL {
    if path.hasPrefix("~") {
        let path = path.removingPercentEncoding ?? path
        return URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
    } else if let url = URL(string: path, relativeTo: baseURL), url.scheme != nil {
        return url
    }

    // Check if url has a scheme
    if baseURL != nil || path.contains(":") {
        let path = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        if let url = URL(string: path, relativeTo: baseURL) {
            return url
        }
    }

    // Assume local path
    if (path as NSString).isAbsolutePath {
        return URL(fileURLWithPath: path.removingPercentEncoding ?? path)
    } else {
        return Bundle.main.resourceURL!.appendingPathComponent(path)
    }
}

// MARK: Approximate equality

private let precision: CGFloat = 0.001

extension CGPoint {
    func isNearlyEqual(to other: CGPoint) -> Bool {
        return abs(x - other.x) <= precision && abs(y - other.y) <= precision
    }
}

extension CGSize {
    func isNearlyEqual(to other: CGSize) -> Bool {
        return abs(width - other.width) <= precision && abs(height - other.height) <= precision
    }
}

extension CGRect {
    func isNearlyEqual(to other: CGRect) -> Bool {
        return size.isNearlyEqual(to: other.size) && origin.isNearlyEqual(to: other.origin)
    }
}

extension UIEdgeInsets {
    func isNearlyEqual(to other: UIEdgeInsets) -> Bool {
        return
            abs(left - other.left) <= precision &&
            abs(right - other.right) <= precision &&
            abs(top - other.top) <= precision &&
            abs(bottom - other.bottom) <= precision
    }
}

// MARK: Backwards compatibility

struct IntOptionSet: OptionSet {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

struct UIntOptionSet: OptionSet {
    let rawValue: UInt
    init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

#if !swift(>=4.1)

    extension Sequence {
        func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
            return try flatMap { try transform($0).map { [$0] } ?? [] }
        }
    }

#endif

#if !swift(>=4)

    extension NSAttributedString {
        struct DocumentType {
            static let html = NSHTMLTextDocumentType
        }

        struct DocumentReadingOptionKey {
            static let documentType = NSDocumentTypeDocumentAttribute
            static let characterEncoding = NSCharacterEncodingDocumentAttribute
        }
    }

    extension NSAttributedStringKey {
        static let foregroundColor = NSForegroundColorAttributeName
        static let font = NSFontAttributeName
        static let paragraphStyle = NSParagraphStyleAttributeName
    }

    extension UIFont {
        typealias Weight = UIFontWeight
    }

    extension UIFont.Weight {
        static let ultraLight = UIFontWeightUltraLight
        static let thin = UIFontWeightThin
        static let light = UIFontWeightLight
        static let regular = UIFontWeightRegular
        static let medium = UIFontWeightMedium
        static let semibold = UIFontWeightSemibold
        static let bold = UIFontWeightBold
        static let heavy = UIFontWeightHeavy
        static let black = UIFontWeightBlack
    }

    extension UIFontDescriptor {
        struct AttributeName {
            static let traits = UIFontDescriptorTraitsAttribute
        }

        typealias TraitKey = NSString
    }

    extension UIFontDescriptor.TraitKey {
        static let weight = UIFontWeightTrait as NSString
    }

    extension UILayoutPriority {
        var rawValue: Float { return self }
        init(rawValue: Float) { self = rawValue }

        static let required = UILayoutPriorityRequired
        static let defaultHigh = UILayoutPriorityDefaultHigh
        static let defaultLow = UILayoutPriorityDefaultLow
        static let fittingSizeLevel = UILayoutPriorityFittingSizeLevel
    }

    extension Int64 {
        init?(exactly number: NSNumber) {
            self.init(exactly: Double(number))
        }
    }

    extension Double {
        init(truncating number: NSNumber) {
            self.init(number)
        }
    }

    extension CGFloat {
        init(truncating number: NSNumber) {
            self.init(number)
        }
    }

    extension Float {
        init(truncating number: NSNumber) {
            self.init(number)
        }
    }

    extension Int {
        init(truncating number: NSNumber) {
            self.init(number)
        }
    }

    extension UInt {
        init(truncating number: NSNumber) {
            self.init(number)
        }
    }

    extension Bool {
        init(truncating number: NSNumber) {
            self.init(number)
        }
    }

#endif

#if !swift(>=4.2)

    extension UIContentSizeCategory {
        static let didChangeNotification = NSNotification.Name.UIContentSizeCategoryDidChange
    }

    extension NSAttributedString {
        typealias Key = NSAttributedStringKey
    }

    extension NSLayoutConstraint {
        typealias Axis = UILayoutConstraintAxis
    }

    extension UIFont {
        typealias TextStyle = UIFontTextStyle
    }

    extension UIFontDescriptor {
        typealias SymbolicTraits = UIFontDescriptorSymbolicTraits
    }

    extension UIAccessibilityTraits {
        static var tabBar: UIAccessibilityTraits {
            if #available(iOS 10, *) {
                return UIAccessibilityTraitTabBar
            }
            preconditionFailure("UIAccessibilityTraitTabBar is not available")
        }

        static let none = UIAccessibilityTraitNone
        static let button = UIAccessibilityTraitButton
        static let link = UIAccessibilityTraitLink
        static let header = UIAccessibilityTraitHeader
        static let searchField = UIAccessibilityTraitSearchField
        static let image = UIAccessibilityTraitImage
        static let selected = UIAccessibilityTraitSelected
        static let playsSound = UIAccessibilityTraitPlaysSound
        static let keyboardKey = UIAccessibilityTraitKeyboardKey
        static let staticText = UIAccessibilityTraitStaticText
        static let summaryElement = UIAccessibilityTraitSummaryElement
        static let notEnabled = UIAccessibilityTraitNotEnabled
        static let updatesFrequently = UIAccessibilityTraitUpdatesFrequently
        static let startsMediaSession = UIAccessibilityTraitStartsMediaSession
        static let adjustable = UIAccessibilityTraitAdjustable
        static let allowsDirectInteraction = UIAccessibilityTraitAllowsDirectInteraction
        static let causesPageTurn = UIAccessibilityTraitCausesPageTurn
    }

    extension UIActivity {
        typealias ActivityType = UIActivityType
    }

    extension UIView {
        typealias ContentMode = UIViewContentMode
        typealias AutoresizingMask = UIViewAutoresizing
        typealias TintAdjustmentMode = UIViewTintAdjustmentMode

        static let noIntrinsicMetric = UIViewNoIntrinsicMetric

        @nonobjc func bringSubviewToFront(_ subview: UIView) {
            bringSubview(toFront: subview)
        }
    }

    extension UIViewController {
        @nonobjc func addChild(_ child: UIViewController) {
            addChildViewController(child)
        }

        @nonobjc func removeFromParent() {
            removeFromParentViewController()
        }
    }

    extension UIControl {
        typealias State = UIControlState
        typealias Event = UIControlEvents
        typealias ContentVerticalAlignment = UIControlContentVerticalAlignment
        typealias ContentHorizontalAlignment = UIControlContentHorizontalAlignment
    }

    extension UIBarButtonItem {
        typealias SystemItem = UIBarButtonSystemItem
        typealias Style = UIBarButtonItemStyle
    }

    extension UIButton {
        typealias ButtonType = UIButtonType
    }

    extension UIActivityIndicatorView {
        typealias Style = UIActivityIndicatorViewStyle
    }

    extension UIProgressView {
        typealias Style = UIProgressViewStyle
    }

    extension UIInputView {
        typealias Style = UIInputViewStyle
    }

    extension UIDatePicker {
        typealias Mode = UIDatePickerMode
    }

    extension UITextField {
        typealias BorderStyle = UITextBorderStyle
        typealias ViewMode = UITextFieldViewMode
    }

    extension UITabBar {
        typealias ItemPositioning = UITabBarItemPositioning
    }

    extension UITabBarItem {
        typealias SystemItem = UITabBarSystemItem
    }

    extension UITableView {
        typealias Style = UITableViewStyle

        static let automaticDimension = UITableViewAutomaticDimension
    }

    extension UITableViewCell {
        typealias CellStyle = UITableViewCellStyle
        typealias AccessoryType = UITableViewCellAccessoryType
        typealias FocusStyle = UITableViewCellFocusStyle
        typealias SelectionStyle = UITableViewCellSelectionStyle
        typealias SeparatorStyle = UITableViewCellSeparatorStyle
    }

    extension UISearchBar {
        typealias Style = UISearchBarStyle
    }

    extension UISegmentedControl {
        typealias Segment = UISegmentedControlSegment
    }

    extension UIScrollView {
        typealias IndicatorStyle = UIScrollViewIndicatorStyle
        typealias IndexDisplayMode = UIScrollViewIndexDisplayMode
        typealias KeyboardDismissMode = UIScrollViewKeyboardDismissMode
    }

    extension UICollectionView {
        typealias ScrollDirection = UICollectionViewScrollDirection
    }

    extension UIStackView {
        typealias Alignment = UIStackViewAlignment
        typealias Distribution = UIStackViewDistribution
    }

    extension UIWebView {
        typealias PaginationMode = UIWebPaginationMode
        typealias PaginationBreakingMode = UIWebPaginationBreakingMode
    }

    extension UIAlertController {
        typealias Style = UIAlertControllerStyle
    }

    extension UIImagePickerController {
        typealias CameraCaptureMode = UIImagePickerControllerCameraCaptureMode
        typealias CameraDevice = UIImagePickerControllerCameraDevice
        typealias CameraFlashMode = UIImagePickerControllerCameraFlashMode
        typealias SourceType = UIImagePickerControllerSourceType
        typealias QualityType = UIImagePickerControllerQualityType
    }

    extension UISplitViewController {
        typealias DisplayMode = UISplitViewControllerDisplayMode
    }

#endif

#if swift(>=4.2)

    // Workaround for https://bugs.swift.org/browse/SR-7879
    extension UIEdgeInsets {
        static let zero = UIEdgeInsets()
    }

#endif
