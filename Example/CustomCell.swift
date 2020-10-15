//
//  CustomCell.swift
//  Example
//
//  Created by Tim Hsieh on 2020/10/15.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

import Foundation
import UIKit
import Eureka

open class TestCell: Cell<String>, CellType {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.gray
        return label
    }()

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        editingAccessoryView = accessoryView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
    }

    open override func update() {
        super.update()
        titleLabel.text = row.value
    }

    @objc func valueChanged() {
        row.value = titleLabel.text
    }
}

// MARK: SwitchRow

open class _TestRow: Row<TestCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class TestRow: _TestRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
