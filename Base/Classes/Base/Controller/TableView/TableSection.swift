//
//  TableSection.swift
//  Base
//
//  Created by remy on 2018/3/22.
//

import UIKit

open class TableSectionItem: NSObject {
    
    public var model: Any?
    public var index: Int?
    public var rows: [TableCellItem] = []
    /// 通过showRows控制section内容
    /// # 使用reloadSections更新视图
    /// # 使用insertRows,deleteRows更新视图会crash
    public var showRows: Bool = true
    public weak var headerSection: TableSection?
    public weak var footerSection: TableSection?
    public var headerViewClass: TableSection.Type?
    open var headerClass: TableSection.Type? {
        return headerViewClass
    }
    public var footerViewClass: TableSection.Type?
    open var footerClass: TableSection.Type? {
        return footerViewClass
    }
    public var headerViewTitle: String?
    open var headerTitle: String? {
        return headerViewTitle
    }
    public var footerViewTitle: String?
    open var footerTitle: String? {
        return footerViewTitle
    }
    public var headerViewHeight: CGFloat?
    open var headerHeight: CGFloat? {
        return headerViewHeight
    }
    public var footerViewHeight: CGFloat?
    open var footerHeight: CGFloat? {
        return footerViewHeight
    }
    public var headerReuseIDSuffix: String = ""
    public var footerReuseIDSuffix: String = ""
    open func reload() {}
}

open class TableSection: UITableViewHeaderFooterView {
    
    public var sectionItem: TableSectionItem? {
        didSet {
            if let item = sectionItem {
                if self.metaTypeName == item.headerClass?.metaTypeName {
                    item.headerSection = self
                } else if self.metaTypeName == item.footerClass?.metaTypeName {
                    item.footerSection = self
                }
            }
            if let item = oldValue {
                if item.headerSection == self {
                    item.headerSection = nil
                } else if item.footerSection == self {
                    item.footerSection = nil
                }
            }
        }
    }
    
    func updateBinding(sectionItem: TableSectionItem?) {
        self.sectionItem = sectionItem
        UIView.performWithoutAnimation {
            updateSection(sectionItem: sectionItem)
        }
    }
    
    open func updateSection(sectionItem: TableSectionItem?) {}
    
    open override func prepareForReuse() {
        self.sectionItem = nil
        super.prepareForReuse()
    }
}
