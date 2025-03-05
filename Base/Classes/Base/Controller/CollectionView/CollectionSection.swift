//
//  CollectionSection.swift
//  Andmix
//
//  Created by remy on 2018/8/8.
//

import UIKit

open class CollectionSectionItem: NSObject {

    public var model: Any?
    public var indexPath: IndexPath?
    public var rows: [CollectionCellItem] = []
    /// 通过showRows控制section内容
    /// # 使用reloadSections更新视图
    /// # 使用insertRows,deleteRows更新视图会crash
    public var showRows: Bool = true
    public weak var headerSection: CollectionSection?
    public weak var footerSection: CollectionSection?
    public var headerViewClass: CollectionSection.Type?
    open var headerClass: CollectionSection.Type? {
        return headerViewClass
    }
    public var footerViewClass: CollectionSection.Type?
    open var footerClass: CollectionSection.Type? {
        return footerViewClass
    }
    public var headerViewSize: CGSize = .zero
    open var headerSize: CGSize {
        return headerViewSize
    }
    public var footerViewSize: CGSize = .zero
    open var footerSize: CGSize {
        return footerViewSize
    }
    public var sectionViewInset: UIEdgeInsets = .zero
    open var sectionInset: UIEdgeInsets {
        return sectionViewInset
    }
    public var sectionViewMinLineSpacing: CGFloat = 0.0
    open var sectionMinLineSpacing: CGFloat {
        return sectionViewMinLineSpacing
    }
    public var sectionViewMinItemSpacing: CGFloat = 0.0
    open var sectionMinItemSpacing: CGFloat {
        return sectionViewMinItemSpacing
    }
    public var headerReuseIDSuffix: String = ""
    public var footerReuseIDSuffix: String = ""
    open func reload() {}
}

open class CollectionSection: UICollectionReusableView {
    
    public var sectionItem: CollectionSectionItem? {
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
    
    func updateBinding(sectionItem: CollectionSectionItem?) {
        self.sectionItem = sectionItem
        UIView.performWithoutAnimation {
            updateSection(sectionItem: sectionItem)
        }
    }
    
    open func updateSection(sectionItem: CollectionSectionItem?) {}
    
    open override func prepareForReuse() {
        self.sectionItem = nil
        super.prepareForReuse()
    }
}
