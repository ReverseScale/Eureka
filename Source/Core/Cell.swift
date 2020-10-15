//  Cell.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

public enum Position {
    case solo
    case first
    case middle
    case last
}

/// Base class for the Eureka cells
open class BaseCell: UITableViewCell, BaseCellType {

    var position: Position = .middle

    var lineView = UIView()

    var isHiddenLine: Bool = false

    open override func layoutSubviews() {
        super.layoutSubviews()
        adjustMyFrame()
        setCorners()
        setLineView()
    }

    func setCorners() {
        let cornerRadius: CGFloat = 8.0
        switch position {
        case .solo: roundCorners(corners: .allCorners, radius: cornerRadius)
        case .first: roundCorners(corners: [.topLeft, .topRight], radius: cornerRadius)
        case .last: roundCorners(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
        default: noCornerMask()
        }
    }

    func adjustMyFrame() {
        guard let widthSuper = superview?.frame.width else {
            return
        }
        frame = CGRect(x: 12, y: frame.minY, width: widthSuper - 24, height: frame.height)
    }

    func setLineView() {
        addSubview(lineView)
        lineView.backgroundColor = UIColor(red: 235/255, green: 237/255, blue: 242/255, alpha: 1)
        lineView.isHidden = isHiddenLine
        lineView.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
    }

    /// Untyped row associated to this cell.
    public var baseRow: BaseRow! { return nil }

    /// Block that returns the height for this cell.
    public var height: (() -> CGFloat)?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    /**
     Function that returns the FormViewController this cell belongs to.
     */
    public func formViewController() -> FormViewController? {
        var responder: AnyObject? = self
        while responder != nil {
            if let formVC = responder as? FormViewController {
              return formVC
            }
            responder = responder?.next
        }
        return nil
    }

    open func setup() {}
    open func update() {}

    open func didSelect() {}

    /**
     If the cell can become first responder. By default returns false
     */
    open func cellCanBecomeFirstResponder() -> Bool {
        return false
    }

    /**
     Called when the cell becomes first responder
     */
    @discardableResult
    open func cellBecomeFirstResponder(withDirection: Direction = .down) -> Bool {
        return becomeFirstResponder()
    }

    /**
     Called when the cell resigns first responder
     */
    @discardableResult
    open func cellResignFirstResponder() -> Bool {
        return resignFirstResponder()
    }
}

/// Generic class that represents the Eureka cells.
open class Cell<T>: BaseCell, TypedCellType where T: Equatable {

    public typealias Value = T

    /// The row associated to this cell
    public weak var row: RowOf<T>!

    private var updatingCellForTintColorDidChange = false

    /// Returns the navigationAccessoryView if it is defined or calls super if not.
    override open var inputAccessoryView: UIView? {
        if let v = formViewController()?.inputAccessoryView(for: row) {
            return v
        }
        return super.inputAccessoryView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    /**
     Function responsible for setting up the cell at creation time.
     */
    open override func setup() {
        super.setup()
    }

    /**
     Function responsible for updating the cell each time it is reloaded.
     */
    open override func update() {
        super.update()
        textLabel?.text = row.title
        if #available(iOS 13.0, *) {
            textLabel?.textColor = row.isDisabled ? .tertiaryLabel : .label
        } else {
            textLabel?.textColor = row.isDisabled ? .gray : .black
        }
        detailTextLabel?.text = row.displayValueFor?(row.value) ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText
    }

    /**
     Called when the cell was selected.
     */
    open override func didSelect() {}

    override open var canBecomeFirstResponder: Bool {
        return false
    }

    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            formViewController()?.beginEditing(of: self)
        }
        return result
    }

    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            formViewController()?.endEditing(of: self)
        }
        return result
    }

    open override func tintColorDidChange() {
        super.tintColorDidChange()

        /* Protection from infinite recursion in case an update method changes the tintColor */
        if !updatingCellForTintColorDidChange && row != nil {
            updatingCellForTintColorDidChange = true
            row.updateCell()
            updatingCellForTintColorDidChange = false
        }
    }

    /// The untyped row associated to this cell.
    public override var baseRow: BaseRow! { return row }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func noCornerMask() {
        layer.mask = nil
    }
}

